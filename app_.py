import seaborn as sns
from palmerpenguins import load_penguins
from shiny import reactive, render
from shiny.express import input, ui
import pandas as pd
import mysql.connector

## change to match your system.
# connect mysql 
config = {
  'user': 'root',
  'password': 'root',
  'host': '127.0.0.1',
  'port': 3306,
  'database': 'final1',
  'raise_on_warnings': True
}
mydb = mysql.connector.connect(**config)
my_cursor = mydb.cursor(dictionary=True)

penguins = load_penguins()

# Bureau List
# def getBureau():
my_cursor.execute(" SELECT * FROM final_project.VW_SHOWPAGE  ")
my_result = my_cursor.fetchall()
df = pd.DataFrame(my_result)
bureau_list = list(df["Department"].unique())
    # return bureau_list

# # Office List
# def getOffice():
my_cursor.execute(" SELECT * FROM final_project.VW_SHOWPAGE  ")
my_result = my_cursor.fetchall()
df = pd.DataFrame(my_result)
office_list = list(df["Office_Branch"].unique())
#     return office_list


# toggle PTO start within last 30 days.

# INSERT PTO to the table 
# https://shiny.posit.co/py/components/inputs/text-box/

ui.page_opts(title="My_Time_Scorpion /p PTO Dashboard", fillable=True)

with ui.sidebar():
    (ui.input_text_area("namearea", "Employee Name", "first_name last_name"),)  
    ui.input_password("password", "Password(Employee_Id)", "mypassword1")  
    ui.input_action_button("action_button", "Submit") 
    ui.input_select("bureaus","Bureau", choices=bureau_list)
    ui.input_select("offices","Office", choices=office_list)
    ui.input_date_range("daterange", "Date range") 
    ui.input_slider("n", "Number of Department", 1, 100, 20)

# Retrive data from MySQL
@render.data_frame
def data():
    show = df.loc[ 
      (df["Department"] == input.bureaus()) & 
      (df["Office_Branch"] == input.offices()) &
      (df["PTO_start"] >= str(input.daterange()[0])) &
      (df["PTO_start"] <= str(input.daterange()[1]))
      ]
    return show

@render.text
def value():
    return f"{input.daterange()[0]} to {input.daterange()[1]}"

@render.plot(alt="A Seaborn histogram on penguin body mass in grams.")  
def plot():
    show = df.loc[ 
      (df["PTO_start"] >= str(input.daterange()[0])) &
      (df["PTO_start"] <= str(input.daterange()[1]))
      ]  
    ax = sns.histplot(data=show, x="Department", bins=input.n())  
    ax.set_title("Number of PTO Staff during the Data Range")
    ax.set_xlabel("Department")
    ax.set_ylabel("Count")
    return ax  

@render.text
def starmark():
    return 

@render.text
def employeename():
    return input.textarea()

 

@render.text()
@reactive.event(input.action_button)
def counter():
    return f"{input.action_button()}"
    