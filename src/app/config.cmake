target_include_directories( 
    ${APP_CURRENT_TARGET}
    PUBLIC
    ${FILAMENT_INCLUDE_DIR}
)

target_link_libraries(
    ${APP_CURRENT_TARGET}
    PUBLIC
    ${FILAMENT_LIBS}
)
