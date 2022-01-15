//versão do Solidity
//pragma solidity ^0.5.3;

//tipos de valores: Basicamente como definir os dados nas funções.
contract Values {
    string public constant stringValue = "myValue";
    bool public myBool = true;
    int public myInt = -1;
    uint public myUInt = 1;
    uint8 public myUint8 = 8;
    uint256 public myUint256 = 99999;
}

//conceito de enuns: geralmente usado para definir estados da aplicação,
//nesse caso é só uma interação de "ativar".
contract Enuns {
    enum State {Waiting, Ready, Active}
    State public state;

    constructor() public {
        state = State.Waiting;
    }

    function activate() public {
        state = State.Active;
    }

    function isActive() public view returns(bool) {
        return state == State.Active;
    }
}

// conceito de structs: aqui se cria uma estrutura, nesse caso tem uma função para adicionar pessoas a um array de dados.
contract Structs {
    uint256 public peopleCount;
    mapping(uint => Person) public people;

    //address é um dado próprio do solidity
    address owner;

    modifier onlyOwner() {
        require (msg.sender == owner);
        _;
    }

    struct Person {
        uint _id;
        string _firstName;
        string _lastName;
    }
    //definindo que o owner é quem fez o deploy do contrato
    constructor() public {
        owner = msg.sender;
    }

    //o modificador onlyOwner diz que apenas quem fez o deploy do contrato pode fazer essa ação,
    //se outra carteira/address tentar usar esta função a transação vai ser automaticamente revertida
    function addPerson(string memory _firstName, string memory _lastName) public onlyOwner {
        incrementCount();
        people[peopleCount] = Person(peopleCount, _firstName, _lastName);
    }

    //exemplo de função interna, pode-se ser usada dentro de outra função como no exemplo acima. 
    //Se esta fosse uma public function então o contador poderia ser incrementado separadamente da adição de pessoas.
    function incrementCount() internal {
        peopleCount += 1;
    }

    /* 
        Também é possivel usar o epoch-time para definir a que momento um contrato começar a ser usado,-
        isso pode ser aplicado no lugar do owner nesse exemplo e ja que os contratos são imutaveis é uma boa- 
        opção para fazer pre-sales ou liberar contratos em datas específicas.
        outro uso util do epoch-time é a possibilidade de "travar" uma carteira principal, para evitar derramamentos.
        Ex:

            int256 public peopleCount = 0;
            mapping(uint => Person) public people; 

            uint256 openingTime = EPOCH-TIME_DA_ABERTURA_AQUI

            modifier onlyWhileOpen() {
                require(block.timestamp >= openingTime)
            }

            struct Person {
                uint _id;
                string _firstName;
                string _lastName;
            }
            
            function addPerson(string memory _firstName, string memory _lastName) public onlyWhileOpen {
            incrementCount();
            people[peopleCount] = Person(peopleCount, _firstName, _lastName);
            }

            function incrementCount() internal {
                    peopleCount += 1;
            }

        Substituindo o código do owner por este, você terá algo semelhante a um "lançamento" do contrato, que só podera ser-
        utilizado quando atingir o epoch-time
        (lembre-se de não colocar um epoch-time muito longo, pois a imutabilidade não permite edições, logo terá que criar outro contrato)

    */ 
}

//exemplo de função de compra de token
contract BuyToken {
    mapping(address => uint256) public balances;
    address payable wallet;

    event Purchase(
        address indexed _buyer, 
        uint256 _amount
    );
    
    constructor(address payable _wallet) public {
        wallet = _wallet;
    }

    //fallback function
    function() external payable {
        buyToken();
    }
    

    //função que compra tokens
    function buyToken() public  payable{
        //compra
        balances[msg.sender] += 1;
        //envio de eth
        wallet.transfer(msg.value);
        //emitindo uma log na interação do contrato
        emit Purchase(msg.sender, 1);
    }
}


//-------------------------------------------------------------------------------------------------------------------

//exemplos de contrato ERC20, usar apenas o conteudo
contract ERC20Exemplo {
    //token ERC20
    contract ERC20Token {
        string public name;

        mapping(address => uint256) public balances;

        function mint() public {
            //usar o [tx.origin] ao inves do [msg.sender]
            //[tx.origin] = se refere ao endereço que fez a interação com o contrato
            //[msg.sender] = pode ser tanto um endereço quando um contrato que fez uma interação com outro.
            //nesse caso quebraria o balance ao usar o [msg.sender] pois o valor do buytoken estaria armazenado no coontrato
            balances[tx.origin] ++;
        }
    }

    contract BuyToken {
        address payable wallet;
        address public token;

        constructor(address payable _wallet, address _token) public {
            wallet = _wallet;
            token = _token;
        }

        function() external payable {
            buyToken();
        }
        
        function buyToken() public  payable{
            //aqui esse contrato está chamando o outro, usando as funções que criamos no erc20token que anteriormente estavam nesse contrato
            ERC20Token(address(token)).mint();
            //envio de eth
            wallet.transfer(msg.value);
        }
    }
}


//nese exemplo o deploy do contrato se vai apenas no "myToken" ja que refenciamos o contrato ERC20Token
contract ERC20Exemplo2 {
    //token ERC20
    contract ERC20Token {
        string public name;

        mapping(address => uint256) public balances;

        constructor(string memory _name) public {
            name = _name;
        }
        
        function mint() public {
            balances[tx.origin] ++;
        }
    }

    //aqui estamos sobrepondo informações de um contrato com outro
    contract MyToken is ERC20Token {
        //codigo abaixo pode ser usado para definir o nome antes do deploy
        //string public name = "ERC20Exemplo"
        
        string public symbol;
        address[] public owners;
        uint256 ownerCount;
        
        //também podemos adicionar novas funcionalidades, não necessariamente precisamos apenas sobreescrever.
        
        //aqui estamos puxando o symbol e o name referenciado no "contrato pai"
        constructor(string memory _name, string memory _symbol) ERC20Token(_name) public {
            symbol = _symbol;
        }

        //contagem 
        function mint() public {
            //"super" da total acesso ao contrato parente, nesse caso o mint do ERC20Token
            super.mint();
            //incremento para a listagem
            ownerCount ++;
            //lista carteiras que fizeram o mint, por id, a partir do 0
            owners.push(msg.sender);
        }
    }
}

//librarys no solidity
//outra opção para usar librarys é criar um arquivo .sol com a mesma versão do solidity e referenciar com um import, para manter a organização
//Ex: import "./Math.sol
contract Librarys {

    //librarys podem ser usadas tanto apra reutilizar código quanto para fazer verificações em valores
    library Math {
        function divide(uint256 a, uint256 b) internal pure returns (uint256) {
            require (b > 0);
            uint256 c =  a / b;
            return c;
        }
    }

    contract MyContract {
        uint256 public value;
        
        //utilizando a função da library que eu criei acima, essa função não permite a interação com o contrato caso a divisão seja para 0, pois gastaria gás desnecessario
        function calculate(uint _value1, uint _value2) public {
            value = Math.divide(_value1, _value2);
        }
    }

}

/*
Links uteis: 
https://docs.openzeppelin.com/contracts/4.x/
https://docs.soliditylang.org/en/v0.8.11/
https://www.tutorialspoint.com/solidity/index.htm
*/