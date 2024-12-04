print("sec: ", end="")
sec = input()
sec = int(sec)

total = 0
cost = 1
for i in range(1, sec + 1):
    total += cost
    if i % 30 == 0:
        cost *= 2
        print(f"cost is up to {cost}, i: {i}")

print(f"total: {total}")
