#!/bin/sh

while getopts n: OPT
do
  case $OPT in
    n) FLAG_NAME=1; APP_NAME="$OPTARG";;
    *) echo "usage: $0 [-n]" >&2
    exit 1 ;;
  esac
done

if [ $FLAG_NAME != 1 ]; then
  echo "APP_NAME is required!! 'sh nextjs-setup.sh -n APP_NAME'"
  exit 1
fi

SCRIPT_DIR="$(basename "$(pwd)")"
echo "project name is ${APP_NAME}"
cd ..
npx create-next-app --ts "$APP_NAME" --use-npm
cd "$APP_NAME" || exit

touch tsconfig.json

npm i --save-dev typescript @types/react @types/node

npm i tailwindcss postcss autoprefixer
npx tailwindcss init -p
sed -i -e "s/purge: \[\],/purge: \['\.\/pages\/\*\*\/\*\.tsx', '\.\/components\/\*\*\/\*\.tsx'\],/g" tailwind.config.js
cp ../"${SCRIPT_DIR}"/globals.css ./styles/globals.css

npx sb init
npm r tailwindcss postcss autoprefixer
npm i tailwindcss@npm:@tailwindcss/postcss7-compat @tailwindcss/postcss7-compat postcss@^7 autoprefixer@^9
mv stories components

sed -i -e "s/\.\.\/stories\/\*\*\/\*\.stories\.mdx/\.\.\/components\/\*\*\/\*\.stories\.mdx/" .storybook/main.js
sed -i -e "s/\.\.\/stories\/\*\*\/\*\.stories\.@(js|jsx|ts|tsx)/\.\.\/components\/\*\*\/\*\.stories\.@(js|jsx|ts|tsx)/" .storybook/main.js
sed -i -e "1s/^/import \'..\/styles\/globals.css\'\n/" .storybook/preview.js

cp ./components/Button.stories.tsx Button.stories.tsx
rm -rf components/
mkdir components
cp ../"${SCRIPT_DIR}"/Button.tsx ./components/Button.tsx
mv Button.stories.tsx ./components/Button.stories.tsx

cp ../"${SCRIPT_DIR}"/tailwind.config.js tailwind.config.js

# prettier and eslint
npm i --save-dev eslint prettier eslint-plugin-react eslint-config-prettier eslint-plugin-prettier @typescript-eslint/parser @typescript-eslint/eslint-plugin
cp ../"${SCRIPT_DIR}"/.eslintrc.json .eslintrc.json
cp ../"${SCRIPT_DIR}"/.eslintignore .eslintignore
cp ../"${SCRIPT_DIR}"/.prettierrc.json .prettierrc.json
cp ../"${SCRIPT_DIR}"/.prettierignore .prettierignore

# install husky and lint-staged
npm i --save-dev husky lint-staged

# adding script in package.json
sed -i -e '/"lint": "next lint",/d' package.json
sed -i -e 's/"build-storybook": "build-storybook"/"build-storybook": "build-storybook",/' package.json
LINE_NUMBER="$(sed -n '/"build-storybook": "build-storybook",/=' package.json)"
LINE_NUMBER=$((LINE_NUMBER + 1))
sed -i -e "${LINE_NUMBER}s/^/    \"lint\": \"eslint . --ext .ts,.js,.tsx,.jsx\",\n/" package.json
LINE_NUMBER=$((LINE_NUMBER + 1))
sed -i -e "${LINE_NUMBER}s/^/    \"lint:fix\": \"eslint --fix . --ext .ts,.js,.tsx,.jsx\",\n/" package.json
LINE_NUMBER=$((LINE_NUMBER + 1))
sed -i -e "${LINE_NUMBER}s/^/    \"format\": \"prettier --write .\"\n/" package.json
LINE_NUMBER=$((LINE_NUMBER + 2)
sed -i -e "${LINE_NUMBER}s/^/  \"lint-staged\": {\n    \"*.{js,jsx,ts,tsx}\": [\n      \"npm run lint\",\n      \"npm run format\"\n    ]\n  },\n/" package.json

# remove .git/ of nextjs-setup.sh
#rm -rf ../.git

# init git of project
git init

# setting up of husky
npx husky-init && npm install
npx husky add .husky/pre-commit "npm run lint:fix"

# start vscode
#mkdir .vscode
#mv ../settings.json ./.vscode/settings.json
#code .