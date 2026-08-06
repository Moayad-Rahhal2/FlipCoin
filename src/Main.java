
import java.util.Random;
import java.util.Scanner;

public class Main {
    private static final Scanner scanner = new Scanner(System.in);
    private static final Random random = new Random();
    static void main() {
        flipCoin();
        System.out.println("s");
    }

    private static void flipCoin() {
        System.out.println("The max number u can enter as int is: "+Integer.MAX_VALUE);
        System.out.println("Enter odd number");
        while (true) {
            int odd = scanner.nextInt();
            if (odd % 2 == 0) {
                System.out.println("Enter odd number plz");
                continue;
            }
            int headCounter = 0;
            int tailCounter = 0;
            int randomNumber;
            for (int i = 1; i <= odd ; i++) {
                randomNumber=random.nextInt(2);
                if(randomNumber==0){
                    headCounter++;
                    if (headCounter==(odd+1)/2){
                        break;
                    }
                }
                if(randomNumber==1){
                    tailCounter++;
                    if (tailCounter==(odd+1)/2){
                        break;
                    }
                }
            }
            System.out.println("Head Counter: "+headCounter);
            System.out.println("Tail Counter: "+tailCounter);
            if (headCounter>tailCounter){
                System.out.println("Head Wins");
            } else {
                System.out.println("Tail Wins");
            }
            System.out.println("Do you want to flip coin? (y/n)");
            while (true) {
                char choice = scanner.next().charAt(0);
                switch (choice) {
                    case 'y' -> flipCoin();
                    case 'n' -> System.exit(0);
                    default -> System.out.println("Wrong choice, enter y/n");
                }
            }
        }
    }

}
