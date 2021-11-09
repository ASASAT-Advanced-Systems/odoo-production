import os
from dotenv import load_dotenv


def main():
	load_dotenv(dotenv_path=__file__.replace(f"{__file__.split(os.path.sep)[-1]}{os.path.sep}{__file__.split(os.path.sep)[-2]}", ''))
	CLIENT_WEBSITE = os.getenv('CLIENT_WEBSITE')
	HTTP_PATH = os.path.join(os.getenv('PRODUCTION_DIR'), os.path.join('nginx', 'default.conf'))
	HTTPS_PATH = os.path.join(os.getenv('PRODUCTION_DIR'), os.path.join(os.path.join('ssl', 'nginx'), 'default.conf'))
	PARAMS_PATH = os.path.join(os.getenv('PRODUCTION_DIR'), os.path.join('scripts', 'params'))

	with open(HTTP_PATH, 'r') as file:
		http_content = file.read()
	with open(HTTPS_PATH, 'r') as file:
		https_content = file.read()
	with open(PARAMS_PATH, 'r') as file:
		params_content = file.read()

	new_http_content = http_content.replace('<CLIENT DOMAIN OR IP>', CLIENT_WEBSITE)
	new_https_content = https_content.replace('<CLIENT DOMAIN>', CLIENT_WEBSITE)
	new_params_content = params_content.replace('paramDir=', f"paramDir={os.path.join(os.path.join(os.getenv('PRODUCTION_DIR'), 'ssl'), 'param')}")

	with open(HTTP_PATH, 'w') as file:
		file.write(new_http_content)
	with open(HTTPS_PATH, 'w') as file:
		file.write(new_https_content)
	with open(PARAMS_PATH, 'w') as file:
		file.write(new_params_content)
	

if __name__ == '__main__':
	main()
