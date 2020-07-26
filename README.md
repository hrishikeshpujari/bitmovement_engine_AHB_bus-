# bitmovement_engine_AHB_bus 
This is a SoC Design project at SJSU. 

Bitmovement Engine is a design that moves data from source to destination based on the below configurations:
1. Source Address (Address from which data is written).
2. Destination Address (Address to which the data is written).
3. Source Offset.
4. Destination Offset.
5. Block Length (in bits).

The device is then hooked on to the AHB bus. There are 2 versions of the project: baby and child.
Baby: SoC on AHB with 1 bitmovement master without arbitration.
Child: SoC on AHB with 2 bitmovement master with round robin arbitration.
