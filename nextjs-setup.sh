#!/bin/sh

while getopts "n:" OPT
do
  case $OPT in
  n) FLAG_NAME=1; APP_NAME="$OPTARG" ;;
  esac
done

# オプションBが指定されている場合
if [[ $FLAG_NAME != 1 ]]; then
  echo "APP_NAMEが指定されていません"
  exit 1
fi


echo "${APP_NAME}"
# npx create-next-app $APP_NAME
touch $APP_NAME
# cd $APP_NAME
# yarn dev
# touch tsconfig.json

# yarn add --dev typescript @types/react @types/node
# yarn add tailwindcss postcss autoprefixer

# npx tailwindcss init -p
# npx sb init

# yarn remove tailwindcss postcss autoprefixer
# yarn add tailwindcss@npm:@tailwindcss/postcss7-compat @tailwindcss/postcss7-compat postcss@^7 autoprefixer@^9
# mv stories components


# yarn add --dev eslint prettier eslint-plugin-react eslint-config-prettier eslint-plugin-prettier @typescript-eslint/parser @typescript-eslint/eslint-plugin

# touch .eslintrc.json .eslintignore

# touch .prettierrc.json .prettierignore

# yarn add --dev husky lint-staged

exit 1