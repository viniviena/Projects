import pyiast
import pandas as pd
import numpy as np

pyiast._VERSION

df_eth = pd.read_csv("ethane_tpl_data.csv")
df_ethylene = pd.read_csv("ethylene_tpl_data.csv")
df_eth

eth_isotherm = pyiast.ModelIsotherm(df_eth,
                                    loading_key = "loading",
                                    pressure_key = "pressure",
                                    model = "Quadratic")

ethylene_isotherm = pyiast.ModelIsotherm(df_ethylene,
                                    loading_key = "loading",
                                    pressure_key = "pressure",
                                    model = "Quadratic")

pyiast.plot_isotherm(eth_isotherm)
pyiast.plot_isotherm(ethylene_isotherm)

total_pressure = 1.0  # total pressure (bar)
y = np.array([0.5, 0.5])  # gas mole fractions
# partial pressures are now P_total * y
# Perform IAST calculation

import timeit
import numpy as np
import matplotlib.pyplot as plt

execution_times = []

for _ in range(10_000):
    start = timeit.default_timer()
    q = pyiast.iast(total_pressure * y, [eth_isotherm, ethylene_isotherm], verboseflag=True)
    stop = timeit.default_timer()
    execution_times.append(stop - start)

mean_time = np.mean(execution_times)
print(mean_time)
std_dev_time = np.std(execution_times)
print(std_dev_time)

plt.hist(execution_times, bins=50, alpha=0.75, color='blue', edgecolor='black')
plt.axvline(mean_time, color='red', linestyle='dashed', linewidth=1, label=f'Mean: {mean_time:.5f}')
plt.axvline(mean_time + std_dev_time, color='green', linestyle='dashed', linewidth=1, label=f'Std Dev: {std_dev_time:.5f}')
plt.axvline(mean_time - std_dev_time, color='green', linestyle='dashed', linewidth=1)
plt.xlabel('Execution Time (seconds)')
plt.ylabel('Frequency')
plt.title('Distribution of Execution Times')
plt.legend()
plt.show()

mean_time

