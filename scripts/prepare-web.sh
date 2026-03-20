#!/bin/sh -ve

# Extrair versão do flutter_vodozemac do pubspec.yaml (removendo ^)
version=$(grep "flutter_vodozemac:" pubspec.yaml | awk '{print $2}' | sed 's/\^//')
echo "Versão encontrada do flutter_vodozemac: $version"

# Clonar repositório na tag correspondente
git clone --branch ${version} --depth 1 https://github.com/famedly/dart-vodozemac.git .vodozemac
cd .vodozemac

# Buildar para web
cargo install flutter_rust_bridge_codegen --locked
flutter_rust_bridge_codegen build-web --dart-root dart --rust-root $(readlink -f rust) --release

cd ..

# Garantir diretório de destino
mkdir -p ./assets/vodozemac/

# Limpar assets antigos
rm -f ./assets/vodozemac/vodozemac_bindings_dart*

# Copiar novos assets
mv .vodozemac/dart/web/pkg/vodozemac_bindings_dart* ./assets/vodozemac/

# Limpar diretório temporário
rm -rf .vodozemac