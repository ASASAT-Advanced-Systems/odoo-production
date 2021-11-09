import os  
from dotenv import load_dotenv
from passlib.context import CryptContext


def main():
	load_dotenv(dotenv_path=__file__.replace(f"{__file__.split(os.path.sep)[-1]}{os.path.sep}{__file__.split(os.path.sep)[-2]}", ''))
	ADMIN_PASSWORD = os.getenv('ADMIN_PASS')
	ODOO_DB = os.getenv('PRODUCTION_DATABASE')
	CLIENT_WEBSITE = os.getenv('CLIENT_WEBSITE')
	BACKUP_DIR = os.path.join(os.getenv('PRODUCTION_DIR'), 'backups')
	PATH = os.path.join(os.getenv('PRODUCTION_DIR'), 'backup.sh')

	with open(PATH, 'r') as file:
		content = file.read()	

	setpasswd = CryptContext(schemes=['pbkdf2_sha512'])
	admin_password = setpasswd.hash(ADMIN_PASSWORD)
	
	new_content = content.replace('backupDir=', f'backupDir={BACKUP_DIR}')
	new_content = new_content.replace('clientWebsite=', f'clientWebsite={CLIENT_WEBSITE}')
	new_content = new_content.replace('odooDatabase=', f'odooDatabase={ODOO_DB}')
	new_content = new_content.replace('adminPassword=', f'adminPassword={admin_password}')

	with open(PATH, 'w') as file:
		file.write(new_content)	


if __name__ == '__main__':
	main()
