//SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.4;

contract MAP {
    //ERC20

    // Public variables of the token
    string public name = "Basic Univesal Coin";
    string public symbol = "BUC";
    uint8 public decimals = 18;
    // 18 decimals is the strongly suggested default, avoid changing it
    uint256 public totalSupply = 10**9 * 10**uint256(decimals);

    // This creates an array with all balances
    mapping(address => uint256) public balance;
    mapping(address => mapping(address => uint256)) public allowance;
    
    //storing time of latest tx for each address 
    mapping(address => uint256) public time;
    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);

    // This generates a public event on the blockchain that will notify clients
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );
    
    uint256 tstamp;
    
    //total share ,that is 100% in the economy
    uint Tshare = 100 * 10**18;
    
    /**
     * Constructor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     */
    constructor() public{ 
        balance[msg.sender] = Tshare; // Give the creator all initial tokens
        tstamp = now;
        constInit();
    }
    
    function balanceOf(address account) public view returns(uint256){
        return (balance[account]*totalSupply)/(10**20);
    }

    /**
     * Internal transfer, only can be called by this contract
     */
    function _transfer(
        address _from,
        address _to,
        uint256 _value
    ) internal {
        //converting value to share
        _value = ((_value * 10**20)/totalSupply);
        
        // Prevent transfer to 0x0 address. Use burn() instead
        require(_to != address(0x0));
        
        // Check if the sender has enough
        require(balance[_from] >= _value);
        
        // Check for overflows
        require(balance[_to] + _value >= balance[_to]);
        
        // Save this for an assertion in the future
        uint256 previousBalances = balance[_from] + balance[_to];
        
        //updating time of their latest transaction
        time[msg.sender] = now;
        
        //calling velocity
        velocity(_value);
        
        // Subtract from the sender
        balance[_from] -= _value;
        
        // Add the same to the recipient
        balance[_to] += _value;
        
        emit Transfer(_from, _to, _value);
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(balance[_from] + balance[_to] == previousBalances);
    }

    /**
     * Transfer tokens
     *
     * Send '_value' tokens to '_to' from your account
     *
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transfer(address _to, uint256 _value)
        public
        returns (bool success)
    {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    /**
     * Transfer tokens from other address
     *
     * Send '_value' tokens to '_to' on behalf of '_from'
     *
     * @param _from The address of the sender
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]); // Check allowance
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    /**
     * Set allowance for other address
     *
     * Allows '_spender' to spend no more than '_value' tokens on your behalf
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     */
    function approve(address _spender, uint256 _value)
        public
        returns (bool success)
    {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    //traded volume in one day
    uint supply; 
    
    //velocity of one day
    uint Velocity;
    
    //avg Velocity of 100 days
    uint public avgVel = 1;
    
    //queue data structure
    mapping(uint256 => uint256) public queue;
    
    //Initializing values to finrst and last
    uint256 first = 1;
    uint256 last = 0;
    
    //function to add elements into queue
    function enqueue(uint _velocity) public {
        last += 1;
        queue[last] = _velocity;
    }
    
    //function to delete elements form queue
    function dequeue() public{
        require(last >= first);  // non-empty queue
        delete queue[first];
        first += 1;
    }
    
    //function to find avg velocity
    function avgVelocity() public {
        uint sup;
        for(uint i=first; i<=last; i++)
        {
            sup += queue[i];
        }
        avgVel = (sup/100);
    }

    function velocity(uint _value) public{
        if(now - tstamp < 300)
        {
            //stores that days trade volume
            supply += _value;
        }
        else if(now - tstamp > 300){
            
            tstamp = now;
            
            //calculating Velocity of that day
            Velocity = ((supply * 10**18)/totalSupply);
            
            //adding new element to queue
            enqueue(Velocity);
            
            //deleting first element
            dequeue();
            
            //Initializes supply to 0
            supply = 0;
            
            //updates avg velocity
            avgVelocity();
            
            //updating totalSupply
            if(avgVel > 10 ** 18)
            {
                totalSupply += ((((avgVel - 10 ** 18)*100)*totalSupply)/100);
            }
            else
            {
                totalSupply -= ((((10 ** 18 - avgVel)*100)*totalSupply)/100);
            }
        }
    }
    
    //function which would only used once to assign 1 to first 100 queue elements
    function constInit() internal{
        for(uint i=0; i<100; i++)
        {
            enqueue(1);
        }
    }
    
    //function to mine tokens
    function mine(address _lost) public{
        require((now - time[_lost]) > 157680000,"this address isnt lost");
        balance[msg.sender] += balance[_lost];
        delete balance[_lost];
        delete time[_lost];
    }
}