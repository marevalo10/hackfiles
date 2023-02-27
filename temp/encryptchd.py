import os
from Cryptodome.Cipher import AES
import pymysql

# Create a connection to the database
def connect_to_db():
    conn = pymysql.connect(
        host='your_host',
        user='your_user',
        password='your_password',
        db='your_db'
    )
    return conn

def encrypt_number(number, key):
    # Generate a random IV of 128 bits
    IV = os.urandom(16)

    # Create AES object in CBC mode
    cipher = AES.new(key, AES.MODE_CBC, IV)

    # Encrypt the number (convert to bytes first)
    number_bytes = str(number).encode()
    padded_number = pad_number(number_bytes)
    ciphertext = cipher.encrypt(padded_number)

    # Return the IV and the ciphertext
    return IV + ciphertext

def decrypt_number(ciphertext, key):
    # Extract the IV from the start of the ciphertext
    IV = ciphertext[:16]
    ciphertext = ciphertext[16:]

    # Create AES object in CBC mode
    cipher = AES.new(key, AES.MODE_CBC, IV)

    # Decrypt the ciphertext and remove padding
    number_bytes = cipher.decrypt(ciphertext)
    return int(number_bytes.decode().rstrip('0'))

def pad_number(number_bytes):
    # Add padding so that the number is a multiple of 16 bytes
    padding_length = 16 - (len(number_bytes) % 16)
    padding = b'0' * padding_length
    return number_bytes + padding

def search_card_number(card_number):
    conn = connect_to_db()
    cur = conn.cursor()
    cur.execute("SELECT card_number FROM card_numbers WHERE card_number = %s", (card_number))
    result = cur.fetchone()
    cur.close()
    conn.close()
    return result

def insert_card_number(card_number, encrypted_card_number):
    conn = connect_to_db()
    cur = conn.cursor()
    cur.execute("INSERT INTO card_numbers (card_number, encrypted_card_number) VALUES (%s, %s)", (card_number, encrypted_card_number))
    conn.commit()
    cur.close()
    conn.close()

def main():
    key = os.urandom(32)
    card_number = 1234567890123456  # Example card number
    encrypted_card_number = encrypt_number
