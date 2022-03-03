# YoLottery

A game where players put X amount of money in a pool and get a randomized amount back.

Below you can find a brain dump and planning for the project…

Problems:
- players need to have a fair probability of randomness and participation. For example if players can put in any amount of money in the pool, a player could game the system by putting $1 in and participate whilst another player bets $100 — asymmetry. One possible solution is to randomize the buy in fee within some range and sign that fee on blockchain so they can’t reroll buy in, but if they can play multiple times it would increase pool
- the game could follow a lottery system where players pay for tickets that increase probability of winning. Assumption -> the probability of winning is relative to the total amount of money in the pool. If the assumption is true, this is also a flawed system because a player could come and bet 50% of the pool and thus have 50% odds. As the player scales their probability (reduce risk) they also scale their rewards so there’s a negative correlation between risk and reward. This is worth thinking about — I’m unsure if this is a good trade off for increasing odds 
- How is the probability distributed based on amount of players? For example if player A created multiple accounts to play the game how would that increase the odds of winning — but wait if there’s a minimum buy in it shouldn’t matter because the player will increase the pot which is equivalent to the ticket system… needs more though
- One way to mitigate this is to create a graph connecting transactions on ETH scanner. If the user has N degrees with another account, they can’t participate in the YoLottery — will have to whitelist addresses. Needs more though

Software Challenges:
- Solidity does not support the ability to call a function at some time interval or specific time period -> One solution is to make it so that a user in the pool can unlock the pool when the timer is up. The user could be incentivized by providing them with a reward from the pool. Could also just write a cron job… but ofc centralized 
- Randomness algorithm needs to be secure -> Chainlink VRF (but costs moneys…) will likely have to use V1 so that I can use Polygon and avoid gas fees
- Distribution algorithm has to be implemented in a way that decimals are not used -> Divide and round numbers. Keep excess amount 

Software:
- oracles for randomness and time (potientially)
- Solidity smart contract 
- Polygon for low gas fees
- React front end
- Node.JS backend if even necessary

Solution:
- Players have to bet minimum amount of money and can bet more than this amount if they want to. The pool is released at some time interval (24 hours / multiple days)
- Simple algo: total - (total * probability split) for N players. After running through algorithm take remaining funds from simple algorithm and redistribute to remaining players: (remaining_funds / N players) + simple_algo_split. 

Business Model:
- take X % fee from pool and/or user participation 

Front end Design:
- black plain cool looking text
- How does it work page 
- Main page has a black, white and yellow pot of gold -> click here and it’ll open the DApp
- Left side is box with wager and how much owed and right side has total pot and countdown
