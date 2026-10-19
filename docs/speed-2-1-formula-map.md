# Formula map — speed-2-1.xlsx

This file documents the formula-to-Dart transcription for each worksheet. Constants and approximations are preserved as written in Excel; blank required inputs stay blank and dependent results show a dash.

## Speed

| Excel cell | Formula | App output / implementation |
|---|---|---|
| W8 | `=C4` | input `rpm` |
| W9 | `=E4/E7` | `ratioPrimaryClutch` |
| W10 | `=C7/C9` | `ratioClutchSprocket` |
| W11 | `=C12/C14` | `ratioFrontRear` |
| W13 | `=W8*W9*W10*W11` | `finalRpm` |
| W17 | `=E14*25.4` | `rimDiameterMm` |
| W18 | `=((E16*2)*25.4)+W17` | `tireDiameterMm` |
| W19 | `=(W18/2)*3.14159*2` | `tireCircumferenceMm` |
| W22 | `=(W13/60)*W19` | `tireRpmMmSec` |
| W24 | `=W22/1000000*3600` | `speedKmh` |\n| E19 | `=W24` | same displayed speed result |

## TvsHP

| Excel cell | Formula | App output / implementation |
|---|---|---|
| G4 | `=D4*0.7376` | `torqueFtLb` |
| D7 | `=G4/D2` | `torqueRatio` |
| L5 | `=(L2*L3)/V2` | `calculatedHp`, V2 = 5252 |
| V8 | `=L8` | input `torqueKg` (same source value) |
| L10 | `=(V8/V9)*V10*(L9/V11)` | `calculatedTorque`, V9 = 1000, V10 = 9.81, V11 = 60 |
| L22 | `=((L18+L19)/(L18+L20))*100` | `balanceFactorPercent` |

## RPM

| Excel cell | Formula | App output / implementation |
|---|---|---|
| Z8 | `=C4` | intake valve diameter source |
| Z9 | `=(C4/2)*(C4/2)` | helper: radius squared |
| Z10 | `=Z9*3.14159` | helper: single-valve area |
| Z12 | `=Z10*C5` | helper: total valve area |
| Z13 | `=Z12/3.14159` | helper: area divided by 3.14159 |
| Z14 | `=SQRT(Z13)` | helper: square root |
| Z15 | `=Z14*2` | `equivalentValveDiameter` / E4 |
| I4 | `=E4*0.275` | `singleValveLift` |
| C7 | `=I7+(E7*2)` | `strokeTotal` |
| Z18 | `=(Z15*Z15)*(2286000)` | RPM numerator |
| Z19 | `=(C6*C6)*C7` | RPM denominator |
| Z21 | `=Z18/Z19` | helper result for C8 |\n| C8 | `=Z21` | `rpm` |

## karbTB

| Excel cell | Formula | App output / implementation |
|---|---|---|
| AD12 | `=D5` | valve diameter source |
| AD13 | `=(AD12/2)*(AD12/2)` | helper: radius squared |
| AD14 | `=AD13*3.14` | helper: single-valve area |
| AD16 | `=AD14*D7` | helper: total valve area |
| AD17 | `=AD16/3.14` | helper: area divided by 3.14 |
| AD18 | `=SQRT(AD17)` | helper: square root |
| AD19 | `=AD18*2` | `equivalentValveDiameter` |
| D10 | `=AD19*0.93` | `carburetorSize` |
| D12 | `=AD19*1.05` | `throttleBodySize` |
| AG27:AG32 | `=AFrow/AErow` | LC135 5S→6S gear ratios table |

## Port

| Excel cell | Formula | App output / implementation |
|---|---|---|
| AD13 | `=D5` | engine CC source |
| AD14 | `=AD13/1000` | displacement in litres |
| AD15 | `=AD14*D7` | displacement × target RPM |
| AD17 | `=AD15^(0.5)` | square root |
| AD18 | `=AD17*AE18` | `portDiameter`, AE18 = 0.8 |
| D10 | `=AD18` | `portDiameter` |
| AD20 | `=PI()*D10/2*D10/2` | `portArea` |
| D11 | `=AD20` | `portArea` |
| AD21 | `=AD20/2` | helper: half area |
| AD22 | `=AD21/3.14` | helper: half area / 3.14 |
| AD23 | `=SQRT(AD22)*2` | base oval height |
| D12 | `=AD23*0.9` | `ovalHeight` |
| D13 | `=D12*2*0.98` | `ovalWidth` |

## Reference sample outputs

These are workbook cached outputs used in `test/calculations_test.dart`:
- Speed: final RPM 1548.79082198; speed 163.13604155 km/j.
- TvsHP: torque 15.828896 ft.lb; torque ratio 0.54078907; calculated HP 28.60243717; calculated torque 28.776; balance factor 51.64179104%.
- RPM: equivalent valve diameter 31.11269837 mm; lift 8.55599205 mm; total stroke 66.7 mm; RPM 7852.33891930.
- karbTB: carburetor 43.40221423 mm; throttle body 49.00249994 mm.
- Port: diameter 37.18064012 mm; area 1085.73442108 mm²; oval height 23.66761448 mm; oval width 46.38852438 mm.
