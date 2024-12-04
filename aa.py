import math


def select_material():
    print("Universium: 1")
    print("Plasma: 2")
    print("White: 3")
    print("Black: 4")
    print("select: ", end="")
    select = input()
    print("--------------")

    match int(select):
        case 1:
            print("T10 Universium")
            return 10000
        case 2:
            print("T0 Plasma")
            return 1000
        case 3:
            print("T3 White")
            return 4000
        case 4:
            print("T6 Black")
            return 7000


plasma_coefficient = select_material()

print("AA: ", end="")
num = input()
num = int(num)

pe = math.floor(math.log(8 * num) / math.log(1.7))
parallel = 2**pe

plasma = 12.4 * plasma_coefficient * parallel
plama = int(plasma)

print(f"PE: {pe}")
print(f"Parallel: {parallel}")
print(f"Plasma: {plasma:,}")
