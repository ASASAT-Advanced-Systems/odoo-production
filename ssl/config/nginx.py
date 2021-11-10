import os
from dotenv import load_dotenv


def main():
	DOTENV_PATH = __file__.replace(f"{__file__.split(os.path.sep)[-3]}{os.path.sep}{__file__.split(os.path.sep)[-2]}{os.path.sep}{__file__.split(os.path.sep)[-1]}", '')
	load_dotenv(dotenv_path=DOTENV_PATH)
	CLIENT_WEBSITE = os.getenv('CLIENT_WEBSITE')
	PATH = os.path.join(os.getenv('PRODUCTION_DIR'), os.path.join(os.path.join('ssl', 'nginx'), 'default.conf'))

	with open(PATH, 'r') as file:
		content = file.read()

	new_content = content.replace('<CLIENT DOMAIN>', CLIENT_WEBSITE)

	with open(PATH, 'w') as file:
		file.write(new_content)
	

if __name__ == '__main__':
	main()
