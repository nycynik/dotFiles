# Testing

## How ot run run interactivly

To test

    # Build and run interactive container
    docker-compose build ubuntu-test
    docker-compose run ubuntu-test

Then, inside the container:

    cd dotfiles
    ./setup.sh

## automated test

Run:

    docker-compose run automoated-test

# Future Ideas

## Create a non-interactive version of the setup script

```
# Add to your setup.sh
NON_INTERACTIVE=${NON_INTERACTIVE:-0}

gather_user_settings() {
    if [[ "$NON_INTERACTIVE" == "1" ]]; then
        # Use default values or read from config
        USERNAME=${USERNAME:-"testuser"}
        USEREMAIL=${USEREMAIL:-"test@example.com"}
        # ... other defaults
        return
    fi

    # Your existing interactive code
    ...
}
```
