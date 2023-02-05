#
# SHLVL
#
# Show current shell level

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

SPACESHIP_SHLVL_SHOW="${SPACESHIP_SHLVL_SHOW=true}"
SPACESHIP_SHLVL_PREFIX="${SPACESHIP_SHLVL_PREFIX=""}"
SPACESHIP_SHLVL_SUFFIX="${SPACESHIP_SHLVL_SUFFIX=" "}"
SPACESHIP_SHLVL_COLOR="${SPACESHIP_SHLVL_COLOR="blue"}"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

spaceship_shlvl() {
  [[ $SPACESHIP_SHLVL_SHOW == false ]] && return

  spaceship::section::v4 \
    --color "$SPACESHIP_SHLVL_COLOR" \
    --prefix "$SPACESHIP_SHLVL_PREFIX" \
    "$SHLVL" \
    --suffix "$SPACESHIP_SHLVL_SUFFIX"
}