function gamebotMoves(game,ngames)
    % ngames refers to how many Monte Carlo simulation you want to run for
    % each potential move.
    
    % Find all the legal moves
    side = game.whoseMove;
    moves = game.possibleMoves;
    
    if isempty(moves)
        % No moves are possible.
        fprintf('No moves remain. Game is over.\n')
        return
        
    elseif length(moves)==1
        % One move is possible. Make it.
        move = moves;
        
    else
        move = pickBestMove(game,moves,side,ngames);
        
    end
    game.makeMove(move,side);
    game.showResult
    
end

function pos = pickBestMove(game,poslist,side,ngames)
    
    % Column 1 is the number of side 1 wins
    % Column 2 is the number of side 2 wins
    % Column 3 is the number of ties
    
    outcomelist = zeros(length(poslist),3);
    
    % Iterate across all legal moves
    % At each point, measure how many wins and losses we can expect
    
    len = length(poslist);
    otherSide = toggleSide(side);
    
    % parfor i = 1:len
    for i = 1:len
        
        % Defend against quick loss with one move look ahead
        % Imagine opponent makes move i
        % Short-circuit and return if you need to block a winning move.
        newGame = game.copy;
        newGame.makeMove(poslist(i),otherSide);
        if newGame.isGameOver == otherSide
            pos = poslist(i);
        else
            % Imagine we make move i
            newGame = game.copy;
            newGame.makeMove(poslist(i),side);
            
            % TODO: Add a check here to short-circuit in the case of
            % immediate victory.
            
            r = playManyGames(newGame,ngames);
            outcomelist(i,:) = r;
        end
    end
    
    % We want to maximize the chance of winning or tying
    % (i.e. minimize the chance of losing).
    
    outcomelist(:,1) = outcomelist(:,1) + outcomelist(:,3);
    outcomelist(:,2) = outcomelist(:,2) + outcomelist(:,3);
    [~,ix] = max(outcomelist);
    
    % Pick the most favorable outcome
    pos = poslist(ix(side));
end

function rTotals = playManyGames(game,ngames)
    % From boardstate b0, play random games and report the results.
    % This code should be agnostic to the rules of the game
    % Input b0: the starting board
    % Input side: who has the next move
    % Input nGames: how many games to play
    % Output r is a 1x3 vector: [1 wins, 2 wins, draw]
    
    rTotals = [0 0 0];
    
    % Try a parfor here
    for i = 1:ngames
        newGame = game.copy;
        gameOver = false;
        while ~gameOver
            
            newGame.makeMove(randomMove(newGame),newGame.whoseMove);
            r = newGame.isGameOver;
            if r
                rTotals(r) = rTotals(r) + 1;
                gameOver = true;
            end
            
        end % while
        
    end % for
    
end % function

function move = randomMove(game)
    
    moves = game.possibleMoves;
    
    % Pick exactly one of the legal moves
    move = moves(randi(length(moves),1,1));
    
end

function sideOut = toggleSide(sideIn)
    sideOut = 3 - sideIn;
end