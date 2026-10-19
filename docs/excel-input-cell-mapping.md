# Excel input-cell mapping — Alang Motor

This mapping was checked against the uploaded workbooks:
- `CR DCR CAM BALANCING updated jan2024-1.xlsx`
- `speed-2-1.xlsx`

The app uses a blue-tinted field to indicate editable user input. Formula outputs are displayed separately and are not editable.

## speed-2-1.xlsx

| Sheet | Excel input cells | App field |
|---|---|---|
| Speed | C4, E4, C7, E7, C9, C12, C14, E14, E16 | RPM, primary ratio, clutch gear, clutch sprocket, front sprocket, rear sprocket, rim inches, tire height inches |
| TvsHP | D2, L2, L3, D4, L8, L9, L18, L19, L20 | HP, torque for HP, RPM for HP, torque N.m, torque kg, RPM torque, rod, weight, piston |
| RPM | C4, C5, C6, E7, I7 | Intake valve diameter, valve count, bore, stroke jack, standard stroke |
| karbTB | D5, D7 | Intake valve diameter, valve count |
| Port | D5, D7 | Engine CC, target RPM |

The gear ratio table on karbTB is reference data, not user input. Intermediate formulas and output cells must not be shown as editable inputs.

## CR DCR CAM BALANCING updated jan2024-1.xlsx

| Sheet | Excel input cells | App field |
|---|---|---|
| CR | B4, B6, E8, G8, B15, B27 | Cylinder count, bore, stroke jack, original stroke, head volume, IVC degrees |
| CAM BALANCING / Actual Data | B7, C7, B8, C8 | Intake open, intake close, exhaust open, exhaust close |
| CAM BALANCING / Actual Data | D7, D8 | Intake tappet, exhaust tappet; source workbook has fixed values, treat as optional settings only if intentionally exposed |
| CAM BALANCING / Balancing IVC and Balancing LSA | Formula cells | Outputs; not editable input fields |
| CAM BALANCING / Cam Pairing | C46 is the initial value; subsequent rows are formulas | Reference table, not general input fields |

Cells B11 (gasket thickness), B13 (deck clearance), and B22 (gasket mm) in the CR sheet are not marked as blue input cells in the supplied workbook. They are therefore not exposed as user-editable fields in the CR form; their calculations currently use zero for those unmarked inputs. If the workbook is later updated to mark them as input cells, the app should be updated accordingly.

## Colour interpretation

- Blue/purple/yellow fill is interpreted per the specific worksheet's own instructions, not as a universal colour rule across every sheet.
- Labels, static reference values, constants, helper cells, and formula cells are not user input merely because they contain a number.
- Formula outputs must remain read-only.
