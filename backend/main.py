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
         
    def display(self):
        print(self.gridPosition)
    
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

                if (lap_num + 1) <= self.total_laps:
                    next_lap_data = laps.pick_laps(lap_num + 1)
                    if next_lap_data.empty:
                        pit_out_raw = None
            

                    else:
                        pit_out_raw = next_lap_data['PitOutTime'].iloc[0]
                else:
                    pit_out_raw = None

                lap_time = lap_data['LapTime'].iloc[0]
                lap_start_time = lap_data['LapStartTime'].iloc[0]


                lap_duration = 120.0 if pd.isna(lap_time) else lap_time.total_seconds()
                lap_start_seconds = None if pd.isna(lap_start_time) else lap_start_time.total_seconds()

                pit_in  = None if pd.isna(pit_in_raw)  else (pit_in_raw  - lap_start_time).total_seconds()
                pit_out = None if pd.isna(pit_out_raw) else (pit_out_raw - lap_start_time).total_seconds()


                telemetry = lap_data.get_telemetry()

                if telemetry.empty:
                    continue

                telemetry = telemetry.iloc[::5]
                telemetry = telemetry.dropna(subset=['X', 'Y', 'Speed'])
                

                if telemetry.empty:
                    continue
                    
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

f1 = F1Telemetry(2026 , 4)

get_lap_batch(start_lap= 1, end_lap= 3)