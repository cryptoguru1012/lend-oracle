module zee_oracle::tokens{

    use std::vector;
    use zee_oracle::config;

    use std::error;
    use std::signer;
    use std::debug;
    use std::string::{Self, String};

    use aptos_framework::simple_map::{Self, SimpleMap}; 


    const ENOT_INITIALZIED : u64 = 1;
    const ENOT_AUTHORIZED : u64 = 2;
    const EALREADY_INITIALIZED :u64 = 3;

    struct Aggregator has key {
        id : u8,
        source : String,
        tokens : SimpleMap<String, Token>, //key = symbol , value = token 
    } 


    struct Token has key, store {
        name : String,
        symbol : String,
        token_details_list :  vector<TokenDetails> // contains a list of all historical prices
    }

    struct TokenDetails has store {
        price : u128,
        decimals : u8,
        last_update : String,

    }


    //////////////////////////Start of  Intiailize Aggregator //////////////////////////////////////////////////
    fun initialize_aggregator_(sender : &signer, id : u8, source : vector<u8>) {
        move_to (sender, Aggregator {
            id : id,
            source : string::utf8(source),
            tokens : simple_map::create()
        });
    }

    #[cmd]
    public entry fun initialize_aggregator(sender : &signer, id : u8, source : vector<u8>) {
        let admin_addr = config::ADMIN_ADDRESS();
        assert!(admin_addr == signer::address_of(sender), error::permission_denied(ENOT_AUTHORIZED));
        assert!(!exists<Aggregator>(admin_addr), error::already_exists(EALREADY_INITIALIZED));

        initialize_aggregator_(sender, id, source);
    }
    //////////////////////////End of Intiailize Aggregator //////////////////////////////////////////////////


    //////////////////////////Start of Intiailize Token //////////////////////////////////////////////////

    fun initialize_token_(admin_addr : address, token_name : vector<u8>, token_symbol : vector<u8>) acquires Aggregator{       
        let aggregator = borrow_global_mut<Aggregator>(admin_addr);
        let tokens = &mut aggregator.tokens;

        let contains_key = simple_map::contains_key<String, Token>(tokens, &string::utf8(token_symbol));
        assert!(!contains_key, error::already_exists(EALREADY_INITIALIZED));

        simple_map::add<String, Token>(tokens, string::utf8(token_symbol) , Token {
            name :  string::utf8(token_name),
            symbol : string::utf8(token_symbol),
            token_details_list : vector::empty()
        });      
    }

    #[cmd]
    public entry fun initialize_token(sender : &signer, token_name : vector<u8>, token_symbol : vector<u8>) acquires Aggregator {
        let admin_addr = config::ADMIN_ADDRESS();
        assert!(admin_addr == signer::address_of(sender), error::permission_denied(ENOT_AUTHORIZED));
        assert!(exists<Aggregator>(admin_addr), error::not_found(ENOT_INITIALZIED));

        initialize_token_(admin_addr,token_name, token_symbol);
    }
    //////////////////////////End of  Intiailize Token //////////////////////////////////////////////////



    //////////////////////////Start of  Add Feed //////////////////////////////////////////////////
    fun add_feed_(admin_addr : address,token_symbol: vector<u8> ,price : u128, decimals : u8, last_update : vector<u8>) acquires Aggregator{
        let aggregator = borrow_global_mut<Aggregator>(admin_addr);
        let tokens = &mut aggregator.tokens;
        let contains_key = simple_map::contains_key<String, Token>(tokens, &string::utf8(token_symbol));

        assert!(contains_key, error::not_found(ENOT_INITIALZIED));

        let token = simple_map::borrow_mut<String, Token>(tokens, &string::utf8(token_symbol));
        let token_details = TokenDetails {
            price : price, 
            decimals : decimals,
            last_update : string::utf8(last_update)
        };

        let token_details_list = &mut token.token_details_list;
        vector::push_back<TokenDetails>(token_details_list, token_details);
    }

    #[cmd]
    public entry fun add_feed(sender : &signer,token_symbol: vector<u8> , price : u128, decimals : u8, last_update : vector<u8>) acquires Aggregator {
        let admin_addr = config::ADMIN_ADDRESS();
        assert!(admin_addr == signer::address_of(sender), error::permission_denied(ENOT_AUTHORIZED));
        assert!(exists<Aggregator>(admin_addr), error::not_found(ENOT_INITIALZIED));
        add_feed_(admin_addr,token_symbol ,price , decimals, last_update );
    }


    // use this only for testing purpose!!
     #[cmd]
    public entry fun add_feed_general(token_symbol: vector<u8> , price : u128, decimals : u8, last_update : vector<u8>) acquires Aggregator {
        let admin_addr = config::ADMIN_ADDRESS();
        add_feed_(admin_addr,token_symbol ,price , decimals, last_update );   
    }
    ////////////////////////// End of Add Feed //////////////////////////////////////////////////


    // This get feed doesn't work, get the data from the accounts directly
    #[cmd]
    public entry fun get_feed(token_symbol : vector<u8>) : (u128, u8, string::String) acquires  Aggregator {
        let admin_addr = config::ADMIN_ADDRESS();

        debug::print(&admin_addr);

        assert!(exists<Aggregator>(admin_addr), error::not_found(ENOT_INITIALZIED));
        let aggregator = borrow_global<Aggregator>(admin_addr);

        let tokens = &aggregator.tokens;
        let contains_key = simple_map::contains_key<String, Token>(tokens, &string::utf8(token_symbol));

        assert!(contains_key, error::not_found(ENOT_INITIALZIED));

        let token = simple_map::borrow<String, Token>(tokens, &string::utf8(token_symbol));
        let token_details_list  = &token.token_details_list; 
        let length = vector::length(token_details_list);

        if(length > 0) {
           let token_details =  vector::borrow<TokenDetails>(token_details_list, length-1);

           (token_details.price, token_details.decimals, token_details.last_update)

        } else {
             (0 , 0,  string::utf8(b"0"))
        }
    }



    public entry fun test_func(token_symbol : vector<u8>) {
        let admin_addr = config::ADMIN_ADDRESS();

        debug::print(&admin_addr);
        debug::print(&token_symbol);
    }


    public entry fun get_feed_general(token_symbol : vector<u8>): (u128, u8, string::String) acquires Aggregator{
        let admin_addr = config::ADMIN_ADDRESS();

        debug::print(&admin_addr);

        let aggregator = borrow_global<Aggregator>(admin_addr);

        let tokens = &aggregator.tokens;
        let contains_key = simple_map::contains_key<String, Token>(tokens, &string::utf8(token_symbol));

        assert!(contains_key, error::not_found(ENOT_INITIALZIED));

        let token = simple_map::borrow<String, Token>(tokens, &string::utf8(token_symbol));
        let token_details_list  = &token.token_details_list; 
        let length = vector::length(token_details_list);

        if(length > 0) {
           let token_details =  vector::borrow<TokenDetails>(token_details_list, length-1);

           (token_details.price, token_details.decimals, token_details.last_update)

        } else {
             (0 , 0,  string::utf8(b"0"))
        }
    }


   

}