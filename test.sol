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