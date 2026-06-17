import fastf1
from fastapi import FastAPI , HTTPException
import pandas as pd
import json

app = FastAPI()


class F1Telemetry:
    def __init__(self , year , raceNo):
        self.session = fastf1.get_session(year, raceNo, 'R')
        self.session.load()
        print("Session loaded ✅")

        self.gridPosition = self.session.results[['FullName' , 'Abbreviation', 'DriverNumber', 'GridPosition' , 'TeamColor']].sort_values('GridPosition')
        self.total_laps   = int(self.session.laps['LapNumber'].max())
        self.data= {}
         
        
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

                

                telemetry = lap_data.get_telemetry()
                if telemetry.empty:
                    continue

                telemetry = telemetry.iloc[::5]
                telemetry = telemetry.dropna(subset=['X', 'Y'])
                
                if telemetry.empty:
                    continue
                    
                x_vals = telemetry['X'].tolist()
                y_vals = telemetry['Y'].tolist()

                # getting the pit in and pit out time 
                pit_in = lap_data['PitInTime'].iloc[0]

                if (lap_num + 1) <= self.total_laps:
                    next_lap_data = laps.pick_laps(lap_num + 1)
                    if next_lap_data.empty:
                        pit_out = None

                    else:
                        pit_out = next_lap_data['PitOutTime'].iloc[0]
                else:
                    pit_out = None

                lap_time = lap_data['LapTime'].iloc[0]
                cum_time = laps[laps['LapNumber'] <= lap_num]['LapTime'].sum()

                # ✅ Handle crashed laps - create lap_duration variable
                if pd.isna(lap_time):
                    lap_duration = 120.0
                else:
                    lap_duration = lap_time.total_seconds()

                if pd.isna(cum_time):
                    cum_time = pd.Timedelta(seconds=0)
                
                lap_start_session_time = lap_data['LapStartTime'].iloc[0]

                pit_in  = None if pd.isna(pit_in)  else (pit_in  - lap_start_session_time).total_seconds()
                pit_out = None if pd.isna(pit_out) else (pit_out - lap_start_session_time).total_seconds()

                self.data[str(lap_num)].append({
                    'driver': driver,
                    'color':  color,
                    'driverNumber': driver_number,
                    'gridPosition': position,
                    'lapStartTime': (cum_time.total_seconds() - lap_duration),
                    'lapDuration':  lap_duration,
                    'pitInTime':    pit_in, 
                    'pitOutTime':   pit_out, 
                    'points': [{'X': x, 'Y': y} for x, y in zip(x_vals, y_vals)], 
                })

            except Exception as e:
                print(f"Skipping {driver} lap {lap_num}: {e}")

        return self.data[str(lap_num)]
    

    def get_circut(self):

        lap = self.session.laps.pick_fastest()

        circut_telemetry = lap.get_telemetry().iloc[::5]

        if circut_telemetry.empty:
            return 
        
        else :
            circut_telemetry = circut_telemetry.dropna(subset=['X', 'Y']) 
            x_vals = circut_telemetry['X'].tolist()
            y_vals = circut_telemetry['Y'].tolist()
            return [
            {'X' : x , 'Y' : y} for x , y in zip(x_vals , y_vals)
            ]
        


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

f1 = F1Telemetry(2026 , 7)

        
