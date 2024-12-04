import math

print("module num: ", end="")
m = input()
m = float(m)

print("computation/s: ", end="")
cps = input()
cps = float(cps)

n = m * (2 * 0.066) / (math.exp(-0.00005 * (m - 1)) + math.exp(0.00003 * cps))

print(f"{n} modules are destroyed per hour.")

power = 10_000_000 * m * 3.37
print(f"{format(power, ',')}/t")
