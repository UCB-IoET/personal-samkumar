#define PAGE_SIZE 256
#define PAGE_EXP 8

#define LOG_ENTRY_LEN 14
#define LOG_START 768

int read_sp(lua_State* L);
int write_sp(lua_State* L);

// I think these should be in libstorm.h
int libstorm_flash_read(lua_State* L);
int libstorm_flash_write(lua_State* L);

#define FLASH_SYMBOLS \
    { LSTRKEY("flash_read_sp"), LFUNCVAL(read_sp) }, \
    { LSTRKEY("flash_write_sp"), LFUNCVAL(write_sp) }, \
    { LSTRKEY("flash_reset_log"), LFUNCVAL(reset_log) }, \
    { LSTRKEY("flash_write_log"), LFUNCVAL(write_log_entry) }, \
    { LSTRKEY("flash_read_log"), LFUNCVAL(read_log_entry) },
