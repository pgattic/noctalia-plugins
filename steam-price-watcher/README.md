# Steam Price Watcher

Monitor Steam game prices and get notified when they reach your target price.

## Features

- 🎮 **Price Monitoring**: Automatically check Steam game prices at configurable intervals
- 🎯 **Target Prices**: Set your desired price for each game
- 🔔 **Desktop Notifications**: Get notified via notify-send when games reach your target price
- 📊 **Visual Indicator**: Bar widget shows a notification dot when games are at target price
- 💰 **Price Comparison**: See current price vs. target price with discount percentages
- ⚙️ **Easy Configuration**: Search games by name or import your Steam wishlist
- 🔄 **Automatic Updates**: Prices are checked automatically based on your interval setting
- 🌍 **Multi-Currency**: Support for 40+ Steam currencies
- 📥 **Wishlist Import**: Import your entire Steam wishlist with one click

## How to Use

### Adding Games to Watchlist

1. Open the plugin settings
2. Enter the game name in the search field
   - Example: "Counter Strike", "GTA", "Cyberpunk"
3. Click "Search"
4. The plugin will show up to 5 matching games
5. Click "Add" on the game you want to monitor
6. Set your target price (the plugin suggests 20% below current price)
7. Click "Add to Watchlist"

### Import Steam Wishlist

The fastest way to add games:

1. Open the plugin settings
2. Find the "Import Steam Wishlist" section
3. Enter your Steam ID or custom URL
   - Example: `76561198012345678` or `yourusername`
4. Click "Import"
5. The plugin will automatically add all games from your wishlist
   - Target prices are set to 20% below current price
   - Free games are skipped
   - Already monitored games are skipped

**Note**: Your Steam profile must be public for import to work.

### Game Search

Alternatively, search for individual games:

- **Counter Strike** → Shows CS:GO, CS2, etc.
- **GTA** → Shows GTA V, GTA IV, etc.
- **Cyberpunk** → Shows Cyberpunk 2077
- **Red Dead** → Shows Red Dead Redemption 2

The search returns up to 5 results. Select the game you want and add it to your watchlist.

### Monitoring Prices

Once games are added to your watchlist:

- The widget will check prices automatically at your configured interval (default: 30 minutes)
- When a game reaches or goes below your target price:
  - A notification dot appears on the bar widget
  - You receive a desktop notification
  - The game is highlighted in the panel
- Click the widget to see all games and their current prices

### Managing Your Watchlist

In the panel (click the widget):

- View all monitored games with current and target prices
- See which games have reached target price (🎯 indicator)
- Edit target prices by clicking the edit icon
- Remove games from watchlist
- Refresh prices manually with the refresh button

### Settings

- **Check Interval**: How often to check prices (15-1440 minutes)
  - Default: 30 minutes
  - ⚠️ Very short intervals may result in many API requests
- **Currency**: Choose from 40+ supported Steam currencies
  - USD, EUR, GBP, BRL, PLN, JPY, CNY, and many more
- **Wishlist Import**: Import games directly from your Steam wishlist
- **Game Search**: Search and add individual games manually

## Technical Details

- **API**: Uses Steam Store API (`store.steampowered.com/api/appdetails`)
- **Wishlist API**: Uses Steam Wishlist API for wishlist imports
- **Currency**: Supports 40+ currencies (USD, EUR, GBP, BRL, PLN, JPY, CNY, RUB, etc.)
- **Data Storage**: Settings are stored in Noctalia's plugin configuration
- **Notifications**: Uses notify-send for desktop notifications

## Requirements

- Noctalia Shell v3.6.0 or higher
- Internet connection for API access
- `curl` command-line tool (for API requests)
- `notify-send` (for desktop notifications)

## Supported Languages

- Portuguese (pt)
- English (en)
- Spanish (es)
- French (fr)
- German (de)
- Italian (it)
- Japanese (ja)
- Dutch (nl)
- Russian (ru)
- Turkish (tr)
- Ukrainian (uk-UA)
- Chinese Simplified (zh-CN)

## Changelog

### Version 1.1.0

- Added Steam Wishlist import feature
- Expanded currency support to 40+ currencies
- All major Steam-supported currencies now available
- Improved user experience for adding games in bulk

### Version 1.0.0

- Initial release
- Steam API integration
- Price monitoring with configurable intervals
- Target price alerts
- Desktop notifications
- Multi-language support

## Author

Lokize

## License

This plugin follows the same license as Noctalia Shell.

## Tips

- Set realistic target prices (20-30% below current price is usually good)
- Don't set check intervals too short (<30 minutes) to avoid excessive API requests
- Games that are free or don't have pricing information cannot be added
- Notifications are sent only once per game until you update the target price
- The plugin remembers which games have been notified to avoid spam

## Troubleshooting

**Problem**: No prices showing
**Solution**: Check your internet connection and verify the App ID is correct

**Problem**: Notifications not appearing
**Solution**: Make sure notify-send is installed and working on your system

**Problem**: "No games found" when searching
**Solution**: Verify the App ID or Name is correct and the game exists on Steam

**Problem**: Prices not updating
**Solution**: Click the refresh button in the panel or wait for the next automatic check

## Future Enhancements

Potential features for future versions:

- Price history tracking and charts
- Historical low price information (integration with SteamDB or ITAD)
- Steam sale event notifications
- Bulk price threshold adjustments
- Export/import watchlist to JSON
