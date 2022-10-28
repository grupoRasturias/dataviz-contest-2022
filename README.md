# Data visualization contest with R: third edition

## About the contest

1.  On **November 1^st^ 2022, the database base will be made publicly available** on [this link](https://drive.google.com/drive/folders/17jmy9er05KDhlGpM6bLfvxA3VSN9bBvA?usp=sharing). Anybody will be able to participate sending a plot made with [R software.](https://www.r-project.org/)

2.  **The project presentation** will take place between **the day the data is published (November 1^st^, 2022) and 11:59 PM on December 15^th^, 2022**, sending an e-mail to **grupousuariosrasturias\@gmail.com** with the visualization or the url to it, in the preferred format. Name, surname, e-mail, professional/laboral background and country of residence will be specified in the e-mail.\
    The subject of the e-mail must include "Third data visualization contest". **A very brief explanatory text in english, can be attached to the graphic.**

3.  The jury will issue its **final decision throught January, 2023**. The declaration will be made public on this repository and our [Twitter](https://twitter.com/grupoRasturias) account, and the winner will be notified by e-mail.

4.  The price amount is **three hundred euros (300 €)** for the first prize and **one hundred euros (100 €)** for the second prize.

5.  Contest's rules and further instructions can be accesed within this repository ().

## About the data

The data for the third Data Visualization Contest with R was retrieved from the {[f1dataR](https://github.com/SCasanova/f1dataR)} package. It consists of Formula 1 (F1) data retrieved from the Ergast API and the official F1 data stream, covering the last three seasons (2019, 2020, 2021). Each year is comprised of several datasets, and they can be imported and read in R with the qread() function from {[qs](https://cran.r-project.org/web/packages/qs/vignettes/vignette.html)}.

## Variables

### Constructor standings

1.  ConstructorID: Name of the motor-racing team
2.  Points
3.  Position: Position in the championship
4.  Round: Number of races
5.  Wins: Number of victories

### Driver standigs

1.  DriverID: Driver
2.  Position: Position in the championship
3.  Points
4.  Wins: Number of victories
5.  ConstructorID: Name of the motor-racing team
6.  Round: Race number

### Drivers

1.  DriverID: Driver
2.  givenName: Name of the driver
3.  FamilyName: Last name of the driver
4.  Nationality
5.  DateOfBirth
6.  Code: Driver's identification
7.  permanentNumber: Driver's number

### Laps

1.  DriverID: Driver
2.  Position: Driver's position
3.  Time: Lap time
4.  Lap: Lap number
5.  Time_sec: Lap time in seconds
6.  Season
7.  Round: Race number

### Pitstops

1.  DriverID: Driver
2.  Lap: Lap when the driver makes the pitstop
3.  Stop: Number of pitstops
4.  Time: Time of the pitstop
5.  Duration: Duration of the pitstop
6.  Round: Race number

### Qualifying

1.  DriverID: Driver
2.  Position: Position in the qualigying
3.  Q1,Q2,Q3: Time in each round of the qualifying
4.  Q1_sec,Q2_sec,Q3_sec: Time in seconds in each round of the qualifying
5.  Round: Race number

### Races

1.  Season
2.  Round: Race number
3.  Race_name: Name of the Grand Prix (race)
4.  Circuit_id: Identification of the circuit
5.  Circuit_name: Name of the circuit
6.  Lat: Latitude
7.  Long: Longitude
8.  Locality: City
9.  Country
10. Date
11. Time: CET time

### Results

1.  DriverID: Driver
2.  Points: Points gained in the race
3.  Position: Final position in the race
4.  Grid: Starting position
5.  Laps: Number of laps
6.  Status: State of the race
7.  Gap: Distance between pilots
8.  Fastest_rank: Fastest lap ranking
9.  Fastest: Fastest lap
10. Top_speed_kph: Top steep achieved (kilometers per hour)
11. Time_sec: Fastest lap in seconds
12. Round: Race number

### Telemetry

1.  Date
2.  SessionTime
3.  DriverAhead
4.  DistanceToDiverAhead
5.  Time
6.  RPM: Motor revolutions
7.  Speed
8.  nGear: Number of gear
9.  Throttle
10. Brake: Brake use (TRUE/FALSE)
11. DRS: DRS use
12. Source: Data source
13. RelativeDistance
14. Status: Car status
15. X,Y,Z: Coordinates in regard to the circuit
16. Distance
17. DriverCode
18. Round: Race number
