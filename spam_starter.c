// Spam detector (Fill-in starter)
// Your job: finish the TODOs so the program decides if an email is spam.

#include <cs50.h>
#include <stdio.h>

int main(void)
{
    // Features of the email (already done for you)
    int links = get_int("Number of links: ");
    int caps = get_int("Words in ALL CAPS: ");
    int known = get_int("Do you know the sender? (1 = yes, 0 = no): ");

    // TODO: Create an int called score.
    // Links and ALL CAPS words should make the score go UP.
    // Knowing the sender should make the score go DOWN.
    // Start with: 3 points per link, 2 points per caps word, minus 5 if you know the sender.


    // TODO: If score is greater than 6, print "SPAM".
    // Otherwise, print "Not spam".
    // Bonus: print the score too, so you can see why it decided.

}
