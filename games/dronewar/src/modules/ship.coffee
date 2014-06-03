class $z.Ship # designed for Gameprez by Thomas Birdsey, http://twitter.com/Tbirdsey
  @viper: -> {path: [
             {pathSegTypeAsLetter: 'M', x: 0,  y: -24, react: true},
             {pathSegTypeAsLetter: 'L', x: 24,  y: 38, react: true},
             {pathSegTypeAsLetter: 'L', x: 9,  y: 58, react: true},
             {pathSegTypeAsLetter: 'L', x: 3,  y: 48, react: true},
             {pathSegTypeAsLetter: 'L', x: -3,  y: 48, react: true},
             {pathSegTypeAsLetter: 'L', x: -9,  y: 58, react: true},
             {pathSegTypeAsLetter: 'L', x: -24,  y:38, react: true},
             {pathSegTypeAsLetter: 'Z'}
          ], url: GameAssetsUrl + "viper.svg", offset: {x: 0, y: 19}, bullet_stroke: 'none', bullet_fill: '#90F ', bullet_size: 4, bullet_speed: 6, bullet_tick: 70}

  @fang: -> {path: [
            {pathSegTypeAsLetter: 'M', x: 10,  y: -20, react: true}, 
            {pathSegTypeAsLetter: 'L', x: 30,  y: -10, react: true}, 
            {pathSegTypeAsLetter: 'L', x: 40,  y: 20, react: true}, 
            {pathSegTypeAsLetter: 'L', x: 30,  y: 50, react: true}, 
            {pathSegTypeAsLetter: 'L', x: 15,  y: 60, react: true}, 
            {pathSegTypeAsLetter: 'L', x: 10,  y: 67, react: true}, 
            {pathSegTypeAsLetter: 'L', x: 5,  y: 70, react: true},
            {pathSegTypeAsLetter: 'L', x: -5,  y: 70, react: true}, 
            {pathSegTypeAsLetter: 'L', x: -10,  y: 67, react: true}, 
            {pathSegTypeAsLetter: 'L', x: -15,  y: 60, react: true}, 
            {pathSegTypeAsLetter: 'L', x: -30,  y: 50, react: true}, 
            {pathSegTypeAsLetter: 'L', x: -40,  y: 20, react: true}, 
            {pathSegTypeAsLetter: 'L', x: -30,  y: -10, react: true}, 
            {pathSegTypeAsLetter: 'L', x: -10,  y: -20, react: true}, 
            {pathSegTypeAsLetter: 'L', x: -5,  y: 40, react: true}, 
            {pathSegTypeAsLetter: 'L', x: 5,  y: 40, react: true}, 
            {pathSegTypeAsLetter: 'Z', react: true}
          ], url: GameAssetsUrl + "fang.svg", offset: {x: 0, y: 25}, bullet_stroke: 'none', bullet_fill: '#C00', bullet_size: 5, bullet_speed: 5, bullet_tick: 80}

  @cobra: -> {path: [{pathSegTypeAsLetter: 'M', x:  8,  y: -26, react: true},  
                        {pathSegTypeAsLetter: 'L', x:  32, y: -14, react: true}, 
                        {pathSegTypeAsLetter: 'L', x:  44, y:  18, react: true}, 
                        {pathSegTypeAsLetter: 'L', x:  32, y:  26, react: true}, 
                        {pathSegTypeAsLetter: 'L', x:  30, y:  18, react: true}, 
                        {pathSegTypeAsLetter: 'L', x: -28, y:  18, react: true}, 
                        {pathSegTypeAsLetter: 'L', x: -32, y:  26, react: true}, 
                        {pathSegTypeAsLetter: 'L', x: -44, y:  18, react: true},
                        {pathSegTypeAsLetter: 'L', x: -32, y: -14, react: true},
                        {pathSegTypeAsLetter: 'L', x: -8,  y: -26, react: true},
                        {pathSegTypeAsLetter: 'L', x: -8,  y: -14, react: true},
                        {pathSegTypeAsLetter: 'L', x:  8,  y: -14, react: true},
                        {pathSegTypeAsLetter: 'Z'}
		   	        ], url: GameAssetsUrl + "cobra.svg", offset: {x: 0, y: 0}, bullet_stroke: 'none', bullet_fill: '#d3bc5f', bullet_size: 4.5, bullet_speed: 5.5, bullet_tick: 90}