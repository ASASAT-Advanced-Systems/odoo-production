import os  
from dotenv import load_dotenv
from passlib.context import CryptContext


def main():
	PATH = os.path.join(__file__.replace(__file__.split('/')[-1], ''), 'backup-cron.sh')
	CURRENT_PATH = f"{__file__.split('/')[-2]}/{__file__.split('/')[-1]}"
	DOTENV_PATH = os.path.join(__file__.replace(CURRENT_PATH, ''), '.env')
	
	load_dotenv(dotenv_path=DOTENV_PATH)
	ADMIN_PASSWORD = os.getenv('ADMIN_PASS')

	with open(PATH, 'r') as file:
		content = file.read()	

	setpasswd = CryptContext(schemes=['pbkdf2_sha512'])
	admin_password = setpasswd.hash(ADMIN_PASSWORD)
	new_content = content.replace('adminPassword=', f'adminPassword={admin_password}')

	with open(PATH, 'w') as file:
		file.write(new_content)	


if __name__ == '__main__':
	main()
