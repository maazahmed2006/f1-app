import fastf1
from fastapi import FastAPI , HTTPException
import pandas as pd
import json

# CACHE_DIR = "C:/Users/Hamza 2/Documents/fastf1_cache"
# fastf1.Cache.enable_cache(CACHE_DIR) 

app = FastAPI()

class F1Telemetry:
    def __init__(self , year , raceNo):
        self.session = fastf1.get_session(year, raceNo, 'R')
        self.session.load()
        print("Session loaded ✅")

        self.gridPosition = self.session.results[['FullName' , 'Abbreviation', 'DriverNumber', 'GridPosition' , 'TeamColor']].sort_values('GridPosition')
        self.total_laps   = int(self.session.laps['LapNumber'].max())
        self.data= {}
         
    def display(self):
        results = self.session.results
        # print(results[['BroadcastName' , 'GridPosition']])

        driver = self.session.laps.pick_drivers(30)
        lapNo = driver[driver['LapNumber'] == 6]
        print(lapNo['PitInTime'].iloc[0])
    def lap_process(self, lap_num):

        
        self.data[str(lap_num)] = []
        for _, row in self.gridPosition.iterrows():
            driver        = row['Abbreviation']
            color         = f"#{row['TeamColor']}"
            driver_number = int(row['DriverNumber'])
            position      = int(row['GridPosition'])
            
            try:
                laps     = self.session.laps.pick_drivers(driver_number)
                lap_data = laps.pick_laps(lap_num)

                if lap_data.empty:                         
                    continue  

                compound = lap_data['Compound'].iloc[0]
                tyre_life = lap_data['TyreLife'].iloc[0]
                fresh_tyre = lap_data['FreshTyre'].iloc[0]


                pit_in_raw = lap_data['PitInTime'].iloc[0]
                next_lap = (lap_num + 1) <= self.total_laps
                lap_start_time = lap_data['LapStartTime'].iloc[0]
                   
                
                # FIX 1: Only execute pit start logic if they ACTUALLY started in the pits
                if lap_num == 1 and not pd.isna(lap_data['PitOutTime'].iloc[0]):
                    pit_out_raw = lap_data['PitOutTime'].iloc[0]

                # If Lap > 1, OR if it's Lap 1 but they started on the grid and pitted normally
                else:
                    if (lap_num + 1) <= self.total_laps:
                        next_lap_data = laps.pick_laps(lap_num + 1)

                        if next_lap_data.empty:
                            next_lap = False
                            pit_out_raw = None

                        else:
                            next_lap = True
                            if not pd.isna(pit_in_raw):
                                pit_out_raw = next_lap_data['PitOutTime'].iloc[0]
                            else:
                                pit_out_raw = None
                            
                            
                            
                    else:
                        next_lap = False
                        pit_out_raw = None

                # Keep your time calculations exactly like this:
                lap_time = lap_data['LapTime'].iloc[0]

                lap_start_seconds = None if pd.isna(lap_start_time) else lap_start_time.total_seconds()

                pit_in  = None if pd.isna(pit_in_raw)  else (pit_in_raw  - lap_start_time).total_seconds()
                pit_out = None if pd.isna(pit_out_raw) else (pit_out_raw - lap_start_time).total_seconds()

                telemetry = lap_data.get_telemetry()
            
                
                if telemetry.empty:
                    continue


                if (pd.isna(lap_time)):
                    session_time = telemetry['SessionTime'].iloc[-1]
                    lap_duration = (session_time - lap_start_time).total_seconds()
                else:
                    lap_duration = lap_time.total_seconds()
           


                telemetry = telemetry.iloc[::5]
                telemetry = telemetry.dropna(subset=['X', 'Y', 'Speed'])
                    
                x_vals = telemetry['X'].tolist()
                y_vals = telemetry['Y'].tolist()
                speed = telemetry['Speed'].tolist()

                self.data[str(lap_num)].append({
                    'driver': driver,
                    'color':  color,
                    'driverNumber': driver_number,
                    'gridPosition': position,
                    'lapStartTime': lap_start_seconds,
                    'lapDuration':  lap_duration,
                    'pitInTime':    pit_in, 
                    'pitOutTime':   pit_out, 
                    'nextLap' : next_lap,
                    'points': [{'X': x, 'Y': y, 'speed' : s} for x, y, s in zip(x_vals, y_vals , speed)], 
                    'tyre' : {
                        'compound' : compound,
                        'tyreLife' : None if pd.isna (tyre_life) else int(tyre_life),
                        'freshTyre' : False if pd.isna(fresh_tyre) else bool(fresh_tyre),
                    },
                })

            except Exception as e:
                print(f"Skipping {driver} lap {lap_num}: {e}")

        return self.data[str(lap_num)]
    

    def get_circut(self):
        lap = self.session.laps.pick_fastest()
        

        # pit lane coordinates-----------------------------
        pitIn_lap = self.session.laps.dropna(subset=['PitInTime']).iloc[0]
        pitIn_telemetry = pitIn_lap.get_telemetry().dropna(subset=['X', 'Y'])

        pitOut_lap = self.session.laps[
            (self.session.laps['DriverNumber'] == pitIn_lap['DriverNumber']) &
            (self.session.laps['LapNumber'] == pitIn_lap['LapNumber'] + 1) 
        ].iloc[0]
        pitOut_telemetry = pitOut_lap.get_telemetry().dropna(subset = ['X' , 'Y'])

        driverName = pitIn_lap['DriverNumber']

        pitIn_Time = pitIn_lap['PitInTime']
        pitOut_Time = pitOut_lap['PitOutTime']

        combined = pd.concat([pitIn_telemetry , pitOut_telemetry])

        pitLane = combined [
        (combined['SessionTime'] >= pitIn_Time) & (combined['SessionTime'] <= pitOut_Time)
        ].iloc[::2]

        pitLanePoints = [
            {'X' : x , 'Y': y} for x, y in zip(pitLane['X'], pitLane['Y'])
            ] 
        # pit lane coordinates-----------------------------
        
        # circuit coordinates------------------------------
        circut_telemetry = lap.get_telemetry().iloc[::5]

        if circut_telemetry.empty:
            return None
        
        else :
            circut_telemetry = circut_telemetry.dropna(subset=['X', 'Y']) 
            x_vals = circut_telemetry['X'].tolist()
            y_vals = circut_telemetry['Y'].tolist()
            circuitPoints = [
                {'X' : x , 'Y' : y} for x , y in zip(x_vals , y_vals)
            ]
        # circuit coordinates------------------------------
        
        # corners and dns coordinates-----------------------
        circuitInfo = self.session.get_circuit_info()
        cornerInfo = circuitInfo.corners

        if (cornerInfo.empty):
             cornerData = []
        else:
             cornerData = []
             for _, row in cornerInfo.iterrows():
                  cornerData.append({
                    'cornerNumber': int(row['Number']),  # use row, not cornerInfo
                    'coordinates': {'X': row['X'], 'Y': row['Y']},
                    'angle':       row['Angle'],
                    'distance':    row['Distance']
                })
        # corners and dns coordinates-----------------------

        # sector coordinates

        telemetry = lap.get_telemetry()  
        sectorData = {} 

        s1_end_time = lap.Sector1Time
        s2_end_time = lap.Sector1Time + lap.Sector2Time
        lap_end_time = lap.LapTime
        
        s1_telemetry = telemetry[
            telemetry['Time'] <= s1_end_time
        ].dropna(subset=['X', 'Y', 'Z'])

        s2_telemetry = telemetry[
            (telemetry['Time'] > s1_end_time) &
            (telemetry['Time'] <= s2_end_time)
        ].dropna(subset=['X', 'Y', 'Z'])

        s3_telemetry = telemetry[
            (telemetry['Time'] > s2_end_time) &
            (telemetry['Time'] <= lap_end_time)
        ].dropna(subset=['X', 'Y', 'Z'])

        print(f"Telemetry Time:{s1_telemetry['Time'].iloc[-1]}")

        print(f"Session Time: {s1_end_time} ")

        sectorData['Sector1'] = [

            {
                'X' : x ,
                'Y' : y ,
            }
            for x , y in zip(s1_telemetry['X'] , s1_telemetry['Y'])
        ]

        sectorData['Sector2'] = [

            {
                'X' : x ,
                'Y' : y ,
            }
            for x , y in zip(s2_telemetry['X'] , s2_telemetry['Y'])
        ]


        sectorData['Sector3'] = [

            {
                'X' : x ,
                'Y' : y ,
            }
            for x , y in zip(s3_telemetry['X'] , s3_telemetry['Y'])
        ]
        # sector coordinates
        




        return {
            'driverNumber'  : driverName,
            'circuit' : circuitPoints,
            'pitLane' : pitLanePoints,
            'cornerData' : cornerData,
            'sectorData' : sectorData
        }
        
    def get_radio(self):
        raceControlMessage = self.session.race_control_messages
        radioData = {}
        print(type(raceControlMessage['Time'].iloc[0]))
        for i in range(self.total_laps):
            radioMessage = raceControlMessage[raceControlMessage['Lap'] == i+1]

            if(radioMessage.empty):
                    continue
            
            lapRadioData = []
            lapRadioData.append({
                'LapNo': int(radioMessage['Lap'].iloc[0]) ,
                'Time' :[ 
                    (t - self.session.t0_date).total_seconds() for t in radioMessage['Time']
                    ],
                'Category' : radioMessage['Category'].tolist() ,
                'Message' : radioMessage['Message'].tolist(),
                'Corner' : [None if pd.isna(s) else int(s) for s in radioMessage['Sector']],
            })
            radioData[str(i+1)] = lapRadioData
        
        with open(f"messages.json" , "w") as f:
            json.dump(radioData , f , indent = 2 )
        return radioData




                
@app.get("/radio")
def get_radioData():
    return f1.get_radio()

                
        

@app.get("/laps/batch/{start_lap}/{end_lap}")
def get_lap_batch(start_lap: int, end_lap: int):
    if start_lap < 1 or start_lap > f1.total_laps:
        raise HTTPException(status_code=400, detail="Invalid start lap")
    
    end_lap = min(end_lap, f1.total_laps)
    
    result = {}
    for lap in range(start_lap, end_lap + 1):
        result[str(lap)] = f1.lap_process(lap)

    with open(f"data.json", "w") as f:
        json.dump(result, f, indent=2)
    
    return result

@app.get("/circuit")
def load_circut():
    data = f1.get_circut()

    if data is None: 
        raise HTTPException(status_code = 404 , detail = 'Circut Data Not Found' )
         
    else:
        with open(f"circuit.json" , "w") as f: 
            json.dump(data , f, indent=2)
        return data
    

@app.get("/info")
def get_info():
    drivers = []
    for _, row in f1.gridPosition.iterrows():
        drivers.append({
            "driverName": row["FullName"],
            "abbreviation": row["Abbreviation"],
            "driverNumber": int(row["DriverNumber"]),
            "gridPosition": int(row["GridPosition"]),
            "teamColor": f"#{row["TeamColor"]}"
        })

    return {
        "totalLaps": f1.total_laps,
        "drivers": drivers
    }

f1 = F1Telemetry(2026 ,  4)
# f1.display()
# f1.get_radio()
# load_circut()

# get_lap_batch(start_lap= 1 , end_lap= 2)