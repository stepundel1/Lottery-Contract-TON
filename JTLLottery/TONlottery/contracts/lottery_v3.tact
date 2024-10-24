import "@stdlib/deploy";
import "@stdlib/ownable";

// Статусы игры
const StatusStarted: Int = 0;
const StatusFinished: Int = 1;

// Условия участия 
const MinTonForStorage: Int = ton("0.2"); 
const MaxPlayers: Int = 5; 
const LotteryTicketPrice: Int = ton("1.1"); 
const LotteryOwnerComission: Int = ton("1"); 

// Структура состояния лотереи
struct LotteryState {
    status: Int;
    players: map<Int, Address>;
    tickets: map<Int, Address>;
    winnerTicket: Int?;
}
// Мета информация
struct LotteryMeta {
    ticketPrice: Int;
    comissionAmount: Int;
}

contract LotteryV3 with Deployable, OwnableTransferable {
    // настройка контракта
    seqno: Int as uint64; 
    owner: Address;
    comissionAddress: Address;

    meta: LotteryMeta;
    state: LotteryState;

    playersCount: Int = 0;
    ticketsCount: Int = 0;
    // инит контракта
    init(seqno: Int, comissionAddress: Address) {
        self.seqno = seqno;
        self.owner = sender();

        self.comissionAddress = comissionAddress;

        self.state = LotteryState{
            status: StatusStarted,
            players: emptyMap(),
            tickets: emptyMap(),
            winnerTicket: null
        };
        // определение мета информации
        self.meta = LotteryMeta{
            ticketPrice: LotteryTicketPrice,
            comissionAmount: LotteryOwnerComission
        };
    }
    // обработка покупки билета 
    receive("Buying a tickets") {
        let value: Int = context().value;
        // ограничения 
        require(self.state.status != StatusFinished, "Game is finished"); 
        require(value == self.meta.ticketPrice, "Invalid ticket price");
        require(self.playersCount < MaxPlayers, "Maximum players reached");
        require(self.isAlreadyParticipate(sender()) == false, "You have already participated");

       
        // регистрация нового игрока 
        self.state.players.set(self.playersCount, sender());
        self.playersCount = self.playersCount + 1;

        // регистрация нового билета 
        self.state.tickets.set(self.ticketsCount + 1, sender());
        self.ticketsCount = self.ticketsCount + 1;
    }
    // обработка окончания игры 
    receive("Finish") {
        // ограничения 
        require(self.playersCount == MaxPlayers, "Maximum number of players not reached");
        require(sender() == self.owner, "Only owner is allowed to finish game");
        require(self.state.status == StatusStarted, "Only started game is allowed to finish");

        nativeRandomizeLt(); // рандомайзер 
        // вычисления и выбор победителя
        let wonAmount: Int = (self.ticketsCount * ton("1") - self.meta.comissionAmount);
        let winnerTicket: Int = random(1, self.ticketsCount + 1);
        let winner: Address = self.state.tickets.get(winnerTicket)!!;

        self.state.winnerTicket = winnerTicket;
        self.state.status = StatusFinished;
        // отправка приза
        send(SendParameters{
            to: winner,
            bounce: false,
            value: wonAmount,
            body: "Congratulation!".asComment(),
            mode: SendIgnoreErrors
        });
    }
    // обработка сбора комиссии
    receive("Collect") {
        // ограничения
        require(sender() == self.owner, "Only owner is allowed to collect");
        require(self.state.status == StatusFinished, "Only finished game can be collected");
        // сброс лотереи
        self.playersCount = 0;
        self.ticketsCount = 0;

        self.state.status = StatusStarted;
        self.state.players = emptyMap();
        self.state.tickets = emptyMap();
        self.state.winnerTicket = null;

        let amount: Int = myBalance() - MinTonForStorage;
        // отправка комиссии
        if (amount > 0) {
            send(SendParameters{
                to: self.comissionAddress,
                bounce: false,
                value: amount,
                body: "System comission".asComment(),
                mode: SendIgnoreErrors
            });
        }
    }
    // функция проверки, участвовал ли уже игрок
    fun isAlreadyParticipate(address: Address): Bool {
        let i: Int = 0;

        while (i < self.playersCount) {
            if (self.state.players.get(i) == address) {
                return true;
            }

            i = i + 1;
        }

        return false;
    }
    // get функции
    get fun playersCount(): Int {
        return self.playersCount;
    }

    get fun ticketsCount(): Int {
        return self.ticketsCount;
    }

    get fun winnerTicket(): Int? {
        return self.state.winnerTicket;
    }

    get fun gameState(): Int {
        return self.state.status;
    }

    get fun players(): map<Int, Address> {
        return self.state.players;
    }

    get fun tickets(): map<Int, Address> {
        return self.state.tickets;
    }

    get fun state(): LotteryState {
        return self.state;
    }

    get fun meta(): LotteryMeta {
        return self.meta;
    }
}


