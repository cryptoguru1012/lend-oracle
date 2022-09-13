module example::oracle{

    use zee_oracle::tokens;
    use std::debug;
    use aptos_framework::string::String;
    use std::signer;
    use std::vector;



    struct Log has key {
        log_prices : vector<LogPrice>,
        host : address
    }


    struct LogPrice has store {
        price : u128,
        decimal : u8,
        last_update : String
    }


    const ENOT_INITIALZIED : u64 = 1;


    public entry fun log_token_feed(sender: &signer, token_symbol : vector<u8>) acquires Log {
        let addr = signer::address_of(sender);
        if (!exists<Log>(addr)) {
            move_to (sender , Log {
                log_prices : vector::empty(),
                host : addr
            });
        };

        let log = borrow_global_mut<Log>(addr);
        let log_prices = &mut log.log_prices;

        let (price, decimal, last_update) = tokens::get_feed(token_symbol);

        vector::push_back(log_prices, LogPrice {
            price : price,
            decimal : decimal,
            last_update : last_update
        });
    }




    public fun get_token_price(token_symbol : vector<u8>) {

        let (price, decimal, last_update) = tokens::get_feed(token_symbol);
        debug::print<u128>(&price);
        debug::print<u8>(&decimal);
        debug::print<String>(&last_update);

    }


    // This wouldn't work as test framework cannot access real-time data YET, here is the commend from @Magnum6
    // "If you mean from real data on chain, no. The testing framework never accesses real nodes. Just inside the testing environment, you can initialize resource accounts. It's just that whatever state of the world you want your test to run in, that state has to be re-created for every single test".
    // #[test()]
    // public fun get_token_price_test() {
    //     get_token_price(b"ETH");
    // }


}