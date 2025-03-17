(function($) {

	// Function will execute automatically when loading into the page
	(function() {
		"use strict"

		// Function to retrieve the the roulette board cells associated with its corresponding button
		function getButtonCells(btn) {
			var cells = btn.data('cells');
			if (!cells || !cells.length) {
				cells = [];
				switch (btn.data('type')) {
					case 'sector':
						// Get numbers associated with each sector of the board
						var nums = sectors[btn.data('sector')];
						for (var i = 0, len = nums.length; i < len; i++) {
							cells.push(table_nums[nums[i]]);
						}
						return cells;
						break;
					case 'num':
					default:
						// Get the numbers associated with each individual number on the board
						var nums = String(btn.data('num')).split(',');
						for (var i = 0, len = nums.length; i < len; i++) {
							cells.push(table_nums[nums[i]]);
						}
						btn.data('cells', cells)
						return btn.data('cells');
						break;
				}
			}
			return cells;
		};

		// Variables for game state, betting classes, and UI components
		var active = true,
			selectors = {
				roulette : '.roulette',
				num : '.num',
				sector : '.sector',
				table_btns : '.controlls .btn'
			},
			classes = {
				red : 'red',
				black : 'black',
				green : 'green',
				hover : 'hover'
			},
			numbers = {
				red : [],
				black : [],
				green : []
			},
			sectors = {
				'1' : [], // 1st row
				'2' : [], // 2nd row
				'3' : [], // 3rd row
				'4' : [], // 1st 12
				'5' : [], // 2nd 12
				'6' : [], // 3rd 12
				'7' : [], // 1 to 18
				'8' : [], // EVEN
				'9' : [], // RED
				'10' : [], // BLACK
				'11' : [], // ODD
				'12' : [], // 19 to 36
			},
			table_nums = {},
			table_sectors = {};

		// Initialize each number element and store all the references
		$(selectors.num).each(function() {
			var $this = $(this),
				color,
				num = Number($this.text());
			// Store the reference to the number element
			table_nums[num] = $this;
			// Assign corresponding colours to each number
			for (var color in numbers) {
				if ($this.hasClass(classes[color])) {
					numbers[color].push(num);
					$this.data('color', color);
				}
			}
		})

		// Initialize each sector element and store the references
		$(selectors.sector).each(function() {
			var $this = $(this),
				color;
			if ($this.hasClass(classes.red)) {
				color = 'red';
			} else if ($this.hasClass(classes.black)) {
				color = 'black';
			} else {
				color = 'sector';
			}
			$this.data('color', color);
			table_sectors[$this.data('sector')] = $this;
		});

		// Sort all numbers by their colours
		for (var color in numbers) {
			numbers[color].sort(function(a, b) { return a - b; });
		}

		// Assign the numbers to the sectors they belong to (from defined variable above)
		for (var i = 1; i <= 36; i++) {
			// Assign the number to a row
			switch (i%3) {
				case 0:
					sectors['1'].push(i);
					break;
				case 1:
					sectors['3'].push(i);
					break;
				case 2:
					sectors['2'].push(i);
					break;
			}

			// Assign the number to a group of dozens
			if (i <= 12) {
				sectors['4'].push(i);
			} else if (i <= 24) {
				sectors['5'].push(i);
			} else {
				sectors['6'].push(i);
			}

			// Assign the number to upper or lower half
			if (i <= 18) {
				sectors['7'].push(i);
			} else {
				sectors['12'].push(i);
			}

			// Assign the number to be odd or even
			if (i%2) {
				sectors['11'].push(i);
			} else {
				sectors['8'].push(i);
			}

			// Assign the number to its colour
			if (numbers.red.indexOf(i) != -1) {
				sectors['9'].push(i);
			} else if (numbers.black.indexOf(i) != -1) {
				sectors['10'].push(i);
			}
		}

		// Click events and button hover UI changes when moving over the roulette board
		var table_btns = $(selectors.table_btns).hover(
			function() {
				hovering=1;
				if (active) {
					var $this = $(this),
						cells = getButtonCells($this);
					for (var i = 0, len = cells.length; i < len; i++) {
						cells[i].addClass(classes.hover);
					}
					var sector = $this.data('sector');
					if (sector) {
						table_sectors[sector].addClass(classes.hover);
					}
				}
			},
			function() {
				hovering=0;
				var $this = $(this),
					cells = getButtonCells($this);
				for (var i = 0, len = cells.length; i < len; i++) {
					cells[i].removeClass(classes.hover);
				}
				var sector = $this.data('sector');
				if (sector) {
					table_sectors[sector].removeClass(classes.hover);
				}
			}
		).mousedown(function(e) {
			var numbers=[];
			if(typeof $(this).data('sector') != 'undefined'){
				if(e.button==2)ChangeBet(36+$(this).data('sector'),-1);
				else ChangeBet(36+$(this).data('sector'),betAmount);
			}
			else{
				numbers=$(this).data('num');

				if(typeof numbers.length ==='undefined')numbers=[numbers];
				else numbers=numbers.split(',');

				if(e.button==2)for(var i=0;i<numbers.length;i++)ChangeBet(numbers[i],-1);
				else for(var i=0;i<numbers.length;i++)ChangeBet(numbers[i],betAmount);
			}
		});
	})();

	// Disable context menu when hovering over a roulette board element/cell
	document.oncontextmenu = function() {if(hovering)return false;};

})(jQuery);

// Send the bet request to the roulette controller and place a chip on the selected cell (IF VALID)
function sendBet(id, amount) {
    fetch('/roulette/submit_roulette_bet', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        },
        body: JSON.stringify({ bet_id: id, amount: amount })
    })
    .then(response => response.json())
    .then(data => {
		document.getElementById('balance').innerText = `Balance: $${data.balance}`;
		if(data.valid_bet == true){
			placeIndividualChip(id)
		}
	})
    .catch(error => console.error("Error:", error));
}

// Called the sendBet() function to handle a POST call to saving the bet in the db
function ChangeBet(id, amount) {
	if(rouletteInPlay){
		return;
	}

    if (amount > 0) {
        sendBet(id, amount);
    } else if (amount < 0) {
        sendBet(id, amount);
    }
}

// Manually call 'payout_bets' which will generate a random number for winning, then award the winners their profits
function placeBet(num) {
    fetch('/roulette/payout_bets', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({winning_num: num})
    })
    .then(response => response.json())
    .then(data => {
		document.getElementById('balance').innerText = `Balance: $${data.balance}`;
    })
    .catch(error => console.error('Error:', error));

	// Remove any chips after a bet/roulette round finishes
	for(var i=0;i<chips.length;i++){
		if(chips[i]!=null)for(var j=0;chips[i].length>0;j++)document.body.removeChild(chips[i].pop());
	}
}

/**** Code for generating chips on the cells ****/
var squares=new Array(48);
var divs=document.getElementsByTagName("div");
for(var i=0;i<divs.length;i++){
	var attr=divs[i].getAttribute("data-num");
	if(attr==null){
		attr=divs[i].getAttribute("data-sector");
		if(attr==null)continue;
		var index=36+parseInt(attr);

		var rekt=divs[i].getBoundingClientRect();
		squares[index]=new Array(2);
		squares[index][1]=rekt.top+10;
		squares[index][0]=rekt.left+16;
	}else{
		if(attr.indexOf(',')!=-1)continue;
		var rekt=divs[i].getBoundingClientRect();
		squares[attr]=new Array(2);
		squares[attr][1]=rekt.top+10;
		squares[attr][0]=rekt.left+16;
	}
}

// Randomly places chip on the selected cell
function rInt(min,max){
	return Math.floor(Math.random() * (max - min + 1)) + min;
}

// Array of chip objects that are placed on each cell of the roulette board
var chips=new Array(48);

// Variable for storing the currently placed chips
var currentChips;

// Function for placing an individual chip
function placeIndividualChip(id){
	// Get the cell the user clicked on based on the ID
	var cell = document.querySelector(`[data-num="${id}"], [data-sector="${id - 36}"]`);
    if (!cell) return;

	// Get the rectangle and create a new image element
    var rect = cell.getBoundingClientRect();
	var img = document.createElement('img');

	// Mapping of bet amounts to chip images
    const chipImages = {
        1: casinoChipRed,
        10: casinoChipBlue,
        25: casinoChipGreen,
        50: casinoChipYellow,
        100: casinoChipPink,
        250: casinoChipPurple,
        500: casinoChipWhite,
        1000: casinoChipBlack
    };

    // Set the image source based on the currently selected bet amount
    img.src = chipImages[betAmount] || casinoChipRed; // Default to red if undefined
	img.style.zIndex="0";
	img.style.position="absolute";

	var rX=rInt(-8,8);
	var rY=rInt(50,55);

	// Adjust for viewport scroll and scaling
	img.style.left = `${rect.left + window.scrollX + cell.clientWidth / 2 - 10}px`;
	img.style.top = `${rect.top + window.scrollY + cell.clientHeight / 2 - 10}px`;

	img.style.width="20px";
	img.style.pointerEvents="none";

	document.body.appendChild(img);

	if(chips[id]==null)chips[id]=new Array(0);
	chips[id].push(img);

	// Append to `currentChips` if not already present
    currentChips.push({ bet_id: id, amount: betAmount });
}

// Function for getting the placed chips
function initializePlacedChips(){
	// Call the placed_chips_request Ruby function
	fetch('/roulette/placed_chips_request', {
		method: 'POST',
		headers: {
		  'Content-Type': 'application/json',
		  'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
		},
		body: JSON.stringify({})
	  })
	  .then(response => response.json())
	  .then(data => {
		  currentChips = data
		  for (var i = 0; i < data.length; i++) {
			id = data[i].bet_id
			amount = data[i].amount

			// Mapping of bet amounts to chip images
			const chipImages = {
				1: casinoChipRed,
				10: casinoChipBlue,
				25: casinoChipGreen,
				50: casinoChipYellow,
				100: casinoChipPink,
				250: casinoChipPurple,
				500: casinoChipWhite,
				1000: casinoChipBlack
			};

			// Get the cell the user clicked on based on the ID
			var cell = document.querySelector(`[data-num="${id}"], [data-sector="${id - 36}"]`);
			if (!cell) return;

			// Get the rectangle and create a new image element
			var rect = cell.getBoundingClientRect();
			var img = document.createElement('img');

			img.src = chipImages[amount] || casinoChipRed;
			img.style.zIndex="0";
			img.style.position="absolute";

			var rX=rInt(-8,8);
			var rY=rInt(50,55);

			// Adjust for viewport scroll and scaling
			img.style.left = `${rect.left + window.scrollX + cell.clientWidth / 2 - 10}px`;
			img.style.top = `${rect.top + window.scrollY + cell.clientHeight / 2 - 10}px`;
			//img.style.left=(squares[id][0]+rX)+"px";
			//img.style.top=(squares[id][1]+rY)+"px";

			img.style.width="20px";
			img.style.pointerEvents="none";

			document.body.appendChild(img);

			if(chips[id]==null)chips[id]=new Array(0);
			chips[id].push(img);
		  }
	  })
	  .catch(error => console.error('Error:', error));
}

// Function for replacing all chips after page refresh or resize
function placeChips(){
	// Make sure currentChips is defined, or return
	if(!Array.isArray(currentChips)) return;

	// Remove all chips from the board (if any)
	for(var i=0;i<chips.length;i++){
		if(chips[i]!=null)for(var j=0;chips[i].length>0;j++)document.body.removeChild(chips[i].pop());
	}

	for (var i = 0; i < currentChips.length; i++) {
		id = currentChips[i].bet_id
		amount = currentChips[i].amount

		// Mapping of bet amounts to chip images
		const chipImages = {
			1: casinoChipRed,
			10: casinoChipBlue,
			25: casinoChipGreen,
			50: casinoChipYellow,
			100: casinoChipPink,
			250: casinoChipPurple,
			500: casinoChipWhite,
			1000: casinoChipBlack
		};

		// Get the cell the user clicked on based on the ID
		var cell = document.querySelector(`[data-num="${id}"], [data-sector="${id - 36}"]`);
		if (!cell) return;

		// Get the rectangle and create a new image element
		var rect = cell.getBoundingClientRect();
		var img = document.createElement('img');

		img.src = chipImages[amount] || casinoChipRed;
		img.style.zIndex="0";
		img.style.position="absolute";

		var rX=rInt(-8,8);
		var rY=rInt(50,55);

		// Adjust for viewport scroll and scaling
		img.style.left = `${rect.left + window.scrollX + cell.clientWidth / 2 - 10}px`;
		img.style.top = `${rect.top + window.scrollY + cell.clientHeight / 2 - 10}px`;
		//img.style.left=(squares[id][0]+rX)+"px";
		//img.style.top=(squares[id][1]+rY)+"px";

		img.style.width="20px";
		img.style.pointerEvents="none";

		document.body.appendChild(img);

		if(chips[id]==null)chips[id]=new Array(0);
		chips[id].push(img);
	}

}

// Function to check if the chat box is clicked so that we can reposition chips
document.addEventListener("DOMContentLoaded", function () {

    let chatDiv = document.querySelector(".header-chat-div");
    if (chatDiv) {
		chatDiv.addEventListener("click", function () {
			// Remove all chips from the board (if any)
			for(var i=0;i<chips.length;i++){
				if(chips[i]!=null)for(var j=0;chips[i].length>0;j++)document.body.removeChild(chips[i].pop());
			}
			setTimeout(placeChips, 500);
		});
    }
});

// Recalculate positions when window resizes
window.addEventListener("resize", placeChips);
window.addEventListener("load", placeChips);
/////////////////////////////////////////

/**** Code for automatically running the place bet part of the roulette game ****/
function timeLeft() {
    const now = new Date();
    const seconds = now.getSeconds();
    return 60000 - (seconds * 1000); // Time left until the next full minute
}

function updateRouletteStartTimer() {
    let rouletteStartTimer = document.getElementById('rouletteStartTimer');
    let progressBar = document.getElementById('progressFill');

    function updateTimer() {
        let remainingTime = timeLeft() / 1000; // Convert to seconds
        //rouletteStartTimer.textContent = remainingTime.toFixed(1) + "s before the roulette spins";

        // Update progress bar width (percentage)
        let percent = (remainingTime / 60) * 100;
        progressBar.style.width = percent + "%";

        // If time reaches zero, reset progress and trigger the spin
        if (remainingTime <= 0) {
            spinWheel();
        }
    }

    // Update every 100ms for a smoother countdown effect
    setInterval(updateTimer, 100);
}

updateRouletteStartTimer();

// Redirect to spinning the roulette on the minute
setTimeout(function () {
    spinWheel();

    // Start an interval that repeats every 60 seconds
    setInterval(spinWheel, 60000);
}, timeLeft());

///////////////////////////////////////////////////////////////////////////////////

/**** Code for spinning the roulette wheel ****/

// Variable for the spinner
var $inner = $('.inner'),
     $spin = $('#spin'),
     $reset = $('#reset'),
     $data = $('.data'),
     $mask = $('.mask'),
     maskDefault = 'Place Your Bets',
     timer = 9000;
var red = [32,19,21,25,34,27,36,30,23,5,16,1,14,9,18,7,12,3];

$reset.hide();

$mask.text(maskDefault);

// Function for spinning the wheel
function spinWheel(){
	console.log("Spinning the Wheel!");
	rouletteInPlay = true;

	// Get the winning number stored in the server
	var randomNumber = Math.floor(Math.random() * 36);
	fetch('/roulette/winning_num_request', {
		method: 'GET',
		headers: {
			'Content-Type': 'application/json',
			'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
		}
	})
	.then(response => response.json())
	.then(data => {
		randomNumber = data.winning_num

		// Animate the ball
		var color = null;
		$inner.attr('data-spinto', randomNumber).find('li:nth-child('+ randomNumber +') input').prop('checked','checked');

		// Remove the place holder
		$('.placeholder').remove();

		// Set a timeout function which changes the mask text
		setTimeout(function() {
			$mask.text('Good Luck!');
		}, timer/2);

		setTimeout(function() {
			$mask.text(maskDefault);
		}, timer+500);

		// Timeout function to remove the disabled attribute when the roulette animation has stopped
		setTimeout(function() {
			$reset.removeClass('disabled').prop('disabled','');

			// Replace the mask value with the value the ball landed on and the colour
			if($.inArray(randomNumber, red) !== -1){ color = 'red'} else { color = 'black'};
			if(randomNumber == 0){color = 'green'};

			$('.result-number').text(randomNumber);
			$('.result-color').text(color);
			$('.result').css({'background-color': ''+color+''});
			$data.addClass('reveal');
			$inner.addClass('rest');
		}, timer);

		// Timeout function to reset the ball after a few seconds
		setTimeout(function(){
			placeBet(randomNumber)
			currentChips = [];
			// remove the spinto data attr so the ball 'resets'
			$inner.attr('data-spinto','').removeClass('rest');
			$(this).hide();
			$spin.show();
			$data.removeClass('reveal');

			// Unlock the betting table
			rouletteInPlay = false;
		}, timer+5000)
	})
	.catch(error => console.error('Error:', error));
}

////////////////////////////////////////////////

/****  Logic for changing chip amounts *****/
const chipData = [
	{ src: casinoChipRed, value: 1},
	{ src: casinoChipBlue, value: 10},
	{ src: casinoChipGreen, value: 25},
	{ src: casinoChipYellow, value: 50},
	{ src: casinoChipPink, value: 100},
	{ src: casinoChipPurple, value: 250},
	{ src: casinoChipWhite, value: 500},
	{ src: casinoChipBlack, value: 1000}
];

// Finds the chipContainer UI element in the HTML
const chipContainer = document.getElementById("chipContainer");

// Dynamically append the chips to the chip container so that the user can switch bet amounts
chipData.forEach((chipInfo, index) => {
	const chip = document.createElement("img");
	chip.src = chipInfo.src;
	chip.classList.add("chip");

	// Set the first chip (red) as selected by default
	if (index === 0) {
		chip.classList.add("selected");
	}

	chip.addEventListener("click", () => {
		document.querySelectorAll(".chip").forEach(c => c.classList.remove("selected"));
		chip.classList.add("selected");

		// Update the global bet amount
		betAmount = chipInfo.value;
	});

	chipContainer.appendChild(chip);
});

/////////////////////////////////////////////

// Call placeChips() initially if you come to the page for the first time
initializePlacedChips()

// Variables for tracking game state, bet amount, and roulette countdown timers
var rouletteInterval = setInterval(updateRouletteStartTimer, 1000);
var rouletteInPlay = false;
let betAmount = 1 // Start with red chip by default
var hovering=0;
