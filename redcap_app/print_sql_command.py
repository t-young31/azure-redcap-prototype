"""
Python script to find the correct sql command to create the tables
in the MySql database. If it doesn't look like they need to be intialised then 
"""
import os
import requests
from bs4 import BeautifulSoup


def mysql_table_create_command() -> str:
    page = requests.post(f"http://localhost:{os.environ['WEBSITES_PORT']}/install.php")
    soup = BeautifulSoup(page.content, "html.parser")
    return soup.find('textarea').text


if __name__ == "__main__":

    index_page = requests.post(f"http://localhost:{os.environ['WEBSITES_PORT']}/index.php")
    index_content = index_page.content.decode()

    if "REDCap cannot communicate with its database server" in index_content:
        raise RuntimeError("Could not connect to the database")
    elif 'Could not find the "redcap_config" database table' in index_content:
        print(mysql_table_create_command())
    else:
        print("none")
