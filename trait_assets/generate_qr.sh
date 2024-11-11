#! /bin/bash

# Function to generate QRs for a chain
generate_chain_qr() {
    local CHAIN_NAME=$1
    local RPC_URL=$2
    local RUNTIME_VERSION=$3

    echo "Generating QR codes for $CHAIN_NAME..."

    # generate specs
    cargo run add-specs -u $RPC_URL --encryption $ENCRYPTION -d

    # copy specs to for_signing
    cp "../files/in_progress/sign_me_add_specs_trait-${CHAIN_NAME}_sr25519" .

    # sign specs
    SIGNATURE=$(cat "sign_me_add_specs_trait-${CHAIN_NAME}_sr25519" | subkey sign --suri "$SIGNER_URI")

    # generate qr
    cargo run make --goal qr --crypto $ENCRYPTION --msg add-specs --payload "sign_me_add_specs_trait-${CHAIN_NAME}_sr25519" --verifier-hex $VERIFIER_HEX --signature-hex $SIGNATURE

    # copy qr to trait_assets
    cp "../files/completed/add_specs_trait-${CHAIN_NAME}-sr25519" ../../trait_assets/

    # generate metadata
    cargo run load-metadata -d -u $RPC_URL

    # copy metadata for signing
    cp "../files/in_progress/sign_me_load_metadata_trait-${CHAIN_NAME}V${RUNTIME_VERSION}" .

    # sign metadata
    SIGNATURE=$(cat "sign_me_load_metadata_trait-${CHAIN_NAME}V${RUNTIME_VERSION}" | subkey sign --suri "$SIGNER_URI")

    # generate qr
    cargo run --release make --goal qr --crypto sr25519 --msg load-metadata --payload "sign_me_load_metadata_trait-${CHAIN_NAME}V${RUNTIME_VERSION}" --verifier-hex $VERIFIER_HEX --signature-hex $SIGNATURE

    # copy qr to trait_assets
    cp "../files/completed/load_metadata_trait-${CHAIN_NAME}V${RUNTIME_VERSION}" ../../trait_assets/
}

# Common variables
ENCRYPTION="sr25519"
SIGNER_URI="visa type melody ice weather finger cupboard mechanic host floor off never"
VERIFIER_HEX="0x6a43359866256bfe6c10b14587d1b761c09a6e4e7bb089b59bcfce2128e4493d"

# Chain-specific configurations
RELAY_RPC="ws://51.91.74.113:15260"
ASSET_HUB_RPC="ws://51.91.74.113:15460"

cd ../rust/generate_message

# Generate QRs for relay chain
generate_chain_qr "relay" $RELAY_RPC "1000"

# Generate QRs for asset-hub chain
generate_chain_qr "asset-hub-runtime" $ASSET_HUB_RPC "1002" 