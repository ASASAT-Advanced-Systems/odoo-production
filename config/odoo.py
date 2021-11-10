import os
from dotenv import load_dotenv
from passlib.context import CryptContext


def main():
	DOTENV_PATH = __file__.replace(f"{__file__.split(os.path.sep)[-2]}{os.path.sep}{__file__.split(os.path.sep)[-1]}", '.env')
	load_dotenv(dotenv_path=DOTENV_PATH)
	ADMIN_PASSWORD = os.getenv('ADMIN_PASS')
	ODOO_PATH = os.path.join(os.getenv('PRODUCTION_DIR'), os.path.join('odoo', 'odoo.conf'))
	DOCKER_PATH = os.path.join(os.getenv('PRODUCTION_DIR'),  'docker-compose.yml')
	CPU_CORES = 2
	LOG_HANDLER = ':WARNING'

	addons_path = ''
	volumes = '# addons here'
	odoo_addons = os.getenv('ADDONS').split(" ")
	enterprise = os.getenv('ENTERPRISE')

	if enterprise == 'yes':
		addons_path += '/mnt/enterprise, '
		volumes += f'\n\t\t\t- ./enterprise:/mnt/enterprise'
  
	for addon in odoo_addons:
		addons_path += f"/mnt/{addon}, "
		volumes += f'\n\t\t\t- ./{addon}:/mnt/{addon}'

	with open(ODOO_PATH, 'r') as file:
		content = file.read()

	setpasswd = CryptContext(schemes=['pbkdf2_sha512'])
	admin_passwd = setpasswd.hash(ADMIN_PASSWORD)
	new_content = content.replace('admin_passwd =', f'admin_passwd = {admin_passwd}')

	# 1 worker -> approximately 6 concurrent requests
	# Workers calculation:
	# worker = 2*(# of CPU cores) + 1
	workers = 2*(CPU_CORES) + 1
	new_content = new_content.replace('workers =', f'workers = {workers}')

	# logging types: 
	# - :INFO
	# - :DEBUG
	# - :WARNING
	# - :ERROR
	new_content = new_content.replace('log_handler =', f'log_handler = {LOG_HANDLER}')

	new_content = new_content.replace('addons_path =', f'addons_path = {addons_path[:-2]}')

	with open(ODOO_PATH, 'w') as file:
		file.write(new_content)

	with open(DOCKER_PATH, 'r') as file:
		content = file.read()
	new_content = content.replace('# addons here', volumes)
	with open(DOCKER_PATH, 'w') as file:
		file.write(new_content)
	

if __name__ == '__main__':
	main()
