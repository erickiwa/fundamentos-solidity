pragma solidity ^0.5.3;
//Solidity

//tipos de valores: Basicamente como definir os dados nas funções.
contract Values {
    string public constant stringValue = "myValue";
    bool public myBool = true;
    int public myInt = -1;
    uint public myUInt = 1;
    uint8 public myUint8 = 8;
    uint256 public myUint256 = 99999;
}

pragma solidity ^0.5.3;

//conceito de enuns: geralmente usado para definir estados da aplicação,
//nesse caso é só uma interação de "ativar".
contract Enuns {
    enum State {Waiting, Ready, Active}
    State public state;

    contructor() public {
        state = State.Waiting;
    }

    function activate() public {
        state = State.Active;
    }

    function isActive() public view returns(bool) {
        return state == State.Active
    }
}

// conceito de structs: aqui se cria uma estrutura, nesse caso tem uma função para adicionar pessoas a um array de dados.
contract Structs {
    uint256 public peopleCount;
    mapping(uint => Person) public people;

    struct Person {
        uint _id;
        string _firstName;
        string _lastName;
    }

    function addPerson(string memory _firstName, string memory _lastName) public {
        incrementCount();
        people[peopleCount] = Person(peopleCount, _firstName, _lastName);
    }

//exemplo de função interna, pode-se ser usada dentro de outra função como no exemplo acima. 
//Se esta fosse uma public function então o contador poderia ser incrementado separadamente da adição de pessoas.
    function incrementCount() internal {
        peopleCount += 1;
    }
}