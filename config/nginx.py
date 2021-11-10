import os
from dotenv import load_dotenv


def main():
	DOTENV_PATH = __file__.replace(f"{__file__.split(os.path.sep)[-2]}{os.path.sep}{__file__.split(os.path.sep)[-1]}", '.env')
	load_dotenv(dotenv_path=DOTENV_PATH)
	IP_ADDRESS = os.getenv('IP_ADDRESS')
	PATH = os.path.join(os.getenv('PRODUCTION_DIR'), os.path.join('nginx', 'default.conf'))

	with open(PATH, 'r') as file:
		content = file.read()

	new_content = content.replace('<IP_ADDRESS>', IP_ADDRESS)

	with open(PATH, 'w') as file:
		file.write(new_content)
	

if __name__ == '__main__':
	main()
