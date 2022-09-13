#[test_only]
module zee_oracle::token_test {

    use zee_oracle::tokens;
    //use std::string;
    use std::debug;
    use std::string;
    use std::signer;

    #[test(sender = @zee_oracle)]
    public fun initialize_aggregator_test(sender : &signer) {
        initialize_aggregator(sender);
    }


    #[test(sender = @zee_oracle)]
    public fun initialize_token_test(sender : &signer) {
        initialize_aggregator(sender);
        tokens::initialize_token(sender, b"ETH_Price", b"ETH");
    }


    #[test(sender = @zee_oracle)]
    #[expected_failure]
    public fun initialize_token_fail_test(sender : &signer) {
        tokens::initialize_token(sender, b"ETH_Price", b"ETH");
    }

    

    #[test(sender = @zee_oracle)]
    public fun add_feed_test(sender : &signer) {
        initialize_aggregator(sender);
        tokens::initialize_token(sender, b"ETH_Price", b"ETH");
        tokens::add_feed(sender, b"ETH" ,180990909090, 8, b"20220817")
    }


    #[test(sender = @zee_oracle)]
    #[expected_failure]
    public fun add_feed_fail_test_1(sender : &signer) {
        tokens::add_feed(sender, b"ETH" ,180990909090, 8, b"20220817")
    }


    #[test(sender = @zee_oracle)]
    #[expected_failure]
    public fun add_feed_fail_test_2(sender : &signer) {
        initialize_aggregator(sender);
        tokens::add_feed(sender, b"ETH" ,180990909090, 8, b"20220817")
    }

    #[test(sender = @zee_oracle)]
    #[expected_failure]
    public fun add_feed_fail_test_3(sender : &signer) {
        tokens::initialize_token(sender, b"ETH_Price", b"ETH");
        tokens::add_feed(sender, b"ETH" ,180990909090, 8, b"20220817")
    }


    #[test(sender = @zee_oracle)]
    public fun get_feed_test(sender : &signer) {
        let addr = signer::address_of(sender);
        debug::print(&addr);
        initialize_aggregator(sender);
        tokens::initialize_token(sender, b"ETH_Price", b"ETH");
        tokens::add_feed(sender, b"ETH" ,180990909090, 8, b"20220817");
        let (price ,decimals, last_update ) = tokens::get_feed(b"ETH");

        assert!(price == 180990909090, 1);
        assert!(decimals == 8, 1);
        assert!(last_update == string::utf8(b"20220817") , 1);

        // let length = tokens::get_feed();

         debug::print(&price);
   
    }


    #[test(sender = @zee_oracle)]
     #[expected_failure]
    public fun get_feed_fail_test(sender : &signer) {
         initialize_aggregator(sender);
        tokens::initialize_token(sender, b"ETH_Price", b"ETH");
        tokens::add_feed(sender, b"ETH" ,180990909090, 8, b"20220817");
        let (_ ,_, _ ) = tokens::get_feed(b"BTC");
    }


    #[test_only]
    fun initialize_aggregator(sender : &signer) {
        tokens::initialize_aggregator(sender,1,b"Coinbase Aggregator");
    }

}