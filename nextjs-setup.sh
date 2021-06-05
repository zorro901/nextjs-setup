#!/bin/sh

while getopts "n:" OPT
do
  case $OPT in
  n) FLAG_NAME=1; APP_NAME="$OPTARG" ;;
  esac
done

if [[ $FLAG_NAME != 1 ]]; then
  echo "APP_NAME is required!! 'sh nextjs-setup.sh -n APP_NAME'"
  exit 1
fi

echo "${APP_NAME}"
npx create-next-app $APP_NAME
cd $APP_NAME

touch tsconfig.json

yarn add --dev typescript @types/react @types/node
mv pages/_app.js pages/_app.tsx
mv pages/index.js pages/index.tsx
mv pages/api/hello.js pages/api/hello.tsx

yarn add tailwindcss postcss autoprefixer
npx tailwindcss init -p
sed -i '' "s/purge: \[\],/purge: \['\.\/pages\/\*\*\/\*\.tsx', '\.\/components\/\*\*\/\*\.tsx'\],/" tailwind.config.js
mv ../globals.css ./styles/globals.css

npx sb init
yarn remove tailwindcss postcss autoprefixer
yarn add tailwindcss@npm:@tailwindcss/postcss7-compat @tailwindcss/postcss7-compat postcss@^7 autoprefixer@^9
mv stories components

sed -i '' 's/\.\.\/stories\/\*\*\/\*\.stories\.mdx/\.\.\/components\/\*\*\/\*\.stories\.mdx/' .storybook/main.js
sed -i '' 's/\.\.\/stories\/\*\*\/\*\.stories\.@(js|jsx|ts|tsx)/\.\.\/components\/\*\*\/\*\.stories\.@(js|jsx|ts|tsx)/' .storybook/main.js
sed -i '' "1s/^/import \"..\/styles\/globals.css\"\n/" .storybook/preview.js

cp ./components/Button.stories.tsx Button.stories.tsx
rm -rf components/
mkdir components
mv ../Button.tsx ./components/Button.tsx
mv Button.stories.tsx ./components/Button.stories.tsx

mv ../tailwind.config.js tailwind.config.js

# prettier and eslint
yarn add --dev eslint prettier eslint-plugin-react eslint-config-prettier eslint-plugin-prettier @typescript-eslint/parser @typescript-eslint/eslint-plugin
touch .eslintrc.json
mv ../.eslintrc.json .eslintrc.json
touch .eslintignore
mv ../.eslintignore .eslintignore
touch .prettierrc.json
mv ../.prettierrc.json .prettierrc.json
touch .prettierignore
mv ../.prettierignore .prettierignore

mkdir .vscode
mv ../settings.json ./.vscode/settings.json

# install husky and lint-staged
yarn add --dev husky lint-staged

# adding script in package.json
sed -i '' 's/"build-storybook": "build-storybook"/"build-storybook": "build-storybook",/' package.json
LINE_NUMBER=`sed -n '/"build-storybook": "build-storybook",/=' package.json`
LINE_NUMBER=`expr ${LINE_NUMBER} \+ 1`
sed -i '' "${LINE_NUMBER}s/^/    \"lint\": \"eslint . --ext .ts,.js,.tsx,.jsx\",\n/" package.json
LINE_NUMBER=`expr ${LINE_NUMBER} \+ 1`
sed -i '' "${LINE_NUMBER}s/^/    \"lint:fix\": \"eslint --fix . --ext .ts,.js,.tsx,.jsx\",\n/" package.json
LINE_NUMBER=`expr ${LINE_NUMBER} \+ 1`
sed -i '' "${LINE_NUMBER}s/^/    \"format\": \"prettier --write .\"\n/" package.json
LINE_NUMBER=`expr ${LINE_NUMBER} \+ 2`
sed -i '' "${LINE_NUMBER}s/^/  \"lint-staged\": {\n    \"*.{js,jsx,ts,tsx}\": [\n      \"yarn lint\",\n      \"yarn format\"\n    ]\n  },\n/" package.json

# remove .git/ of nextjs-setup.sh
rm -rf ../.git

# init git of project
git init

# setting up of husky
npx husky init
npx husky install
npx husky add .husky/pre-commit "yarn lint-staged"

# start vscode
code .

exit 1
