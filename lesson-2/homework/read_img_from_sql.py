import pyodbc # SQL SERVER

con_str = "DRIVER={ODBC Driver 17 for SQL Server};SERVER=KINGCODE\\SQLEXPRESS;DATABASE=lesson2;Trusted_Connection=yes;"
con = pyodbc.connect(con_str)
cursor = con.cursor()

cursor.execute(
    """
    SELECT * FROM photos;
    """
)

row = cursor.fetchone()
img_id, name, image_data = row

image_path = fr'sql_homeworks\lesson-2\homework\images\{name}.png'

with open(image_path, 'wb') as f:
    f.write(image_data)

print(f'Success! Image saved in: {image_path}')    