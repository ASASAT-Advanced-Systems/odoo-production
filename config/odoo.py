import os
from dotenv import load_dotenv
from passlib.context import CryptContext


def main():
	PATH = os.path.join(__file__.replace(__file__.split('/')[-1], ''), 'odoo.conf')
	CURRENT_PATH = f"{__file__.split('/')[-2]}/{__file__.split('/')[-1]}"
	DOTENV_PATH = os.path.join(__file__.replace(CURRENT_PATH, ''), '.env')

	load_dotenv(dotenv_path=DOTENV_PATH)
	ADMIN_PASSWORD = os.getenv('ADMIN_PASS')

	CPU_CORES = 2
	LOG_HANDLER = ':WARNING'

	with open(PATH, 'r') as file:
		content = file.read()

	setpasswd = CryptContext(schemes=['pbkdf2_sha512'])
	admin_passwd = setpasswd.hash(ADMIN_PASSWORD)
	new_content = content.replace('admin_passwd = ', f'admin_passwd = {admin_passwd}')
	
	# 1 worker -> approximately 6 concurrent requests
	# Workers calculation:
	# worker = 2*(# of CPU cores) + 1
	workers = 2*(CPU_CORES) + 1
	new_content = new_content.replace('workers = ', f'workers = {workers}')

	# logging types: 
	# - :INFO
	# - :DEBUG
	# - :WARNING
	# - :ERROR
	new_content = new_content.replace('log_handler = ', f'log_handler = {LOG_HANDLER}')
	
	with open(PATH, 'w') as file:
		file.write(new_content)
	

if __name__ == '__main__':
	main()
