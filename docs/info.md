# Máquina Expendedora Digital - Proyecto Tiny Tapeout

##  Descripción general

Este proyecto implementa una **máquina expendedora digital** mediante una máquina de estados finitos (FSM), diseñada para ser integrada en el flujo de fabricación de silicio de [Tiny Tapeout](https://tinytapeout.com/). 

El diseño simula el comportamiento de una expendedora que acepta monedas mediante botones (`Up`, `Left`, `Right`, `Down`) y entrega bebidas según el crédito acumulado. La máquina cuenta con tres productos posibles (bebidas), indicados por tres salidas (`LEDs`).

##  Funcionamiento del chip

El chip está basado en una **FSM de 4 estados**, que representa la cantidad de monedas insertadas:

| Estado | Crédito acumulado | Acciones posibles                      |
|--------|-------------------|----------------------------------------|
| S0     | $0                | Insertar moneda (`Up`) → va a S1       |
| S1     | $1                | `Up` → S2, `Left` → compra bebida 1    |
| S2     | $2                | `Up` → S3, `Left` o `Right` → compra   |
| S3     | $3+               | `Left`, `Right` o `Down` → compra      |

###  Entradas (`ui_in`)
- `ui[0]` = BTN_U → Insertar moneda
- `ui[1]` = BTN_L → Comprar bebida 1
- `ui[2]` = BTN_R → Comprar bebida 2
- `ui[3]` = BTN_D → Comprar bebida 3
- `rst_n`  → Reset activo en bajo (BTN_C)

###  Salidas (`uo_out`)
- `uo[0]` = LED encendido si se compra bebida 1
- `uo[1]` = LED encendido si se compra bebida 2
- `uo[2]` = LED encendido si se compra bebida 3

