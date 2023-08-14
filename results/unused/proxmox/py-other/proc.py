import pandas as pd

df = pd.read_csv('filename.csv')

prefixes = ['mle', 'var.fim', 'lowers', 'uppers', 'coverages'] # add or remove prefixes as needed

for prefix in prefixes:
    for col in df.columns:
        if col.startswith(f'{prefix}.'):
            j = int(col.split('.')[1])
            if j % 2 == 0:
                df.rename(columns={col: f'{prefix}.scale.{j//2 + 1}'}, inplace=True)
            else:
                df.rename(columns={col: f'{prefix}.shape.{j//2}'}, inplace=True)

df.to_csv('filename.csv', index=False)
