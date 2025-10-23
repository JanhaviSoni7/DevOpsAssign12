from selenium import webdriver
driver = webdriver.Chrome()
driver.get("http://54.86.208.143:8000")
print(driver.title)
driver.quit()
