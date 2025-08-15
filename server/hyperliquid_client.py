import os
from hyperliquid.info import Info
from hyperliquid.exchange import Exchange
from hyperliquid.utils import get_private_key

class HyperliquidClient:
    def __init__(self):
        self.private_key = get_private_key(os.getenv("HYPERLIQUID_API_PRIVATE_KEY"))
        self.api_wallet_address = os.getenv("HYPERLIQUID_API_WALLET_ADDRESS")
        self.info_client = Info(base_url="https://api.hyperliquid.xyz/info") # Testnet info URL
        self.exchange_client = Exchange(self.private_key, base_url="https://api.hyperliquid.xyz/exchange") # Testnet exchange URL

    def get_eth_price(self):
        # This will fetch the current price of ETH-USDC perpetual
        # The symbol might vary, need to confirm from Hyperliquid docs
        # For now, assuming 'ETH-USDC'
        try:
            # Assuming get_all_mids() returns a list of dictionaries with 'coin' and 'markPx'
            mids = self.info_client.get_all_mids()
            for mid in mids:
                if mid['coin'] == 'ETH': # Assuming 'coin' is the key for the asset
                    return float(mid['markPx'])
            return None
        except Exception as e:
            print(f"Error fetching ETH price: {e}")
            return None

    def get_usdc_balance(self):
        # This will fetch the USDC balance for the main account associated with the API wallet
        # The API wallet address is for signing, but account data is queried using the master account.
        # For simplicity, we'll use the API wallet address as the account address for now,
        # but this might need adjustment based on Hyperliquid's exact requirements for querying balances.
        try:
            # Assuming get_user_state() returns a dictionary with 'assets'
            user_state = self.info_client.get_user_state(self.api_wallet_address)
            for asset in user_state['assets']:
                if asset['token'] == 'USDC':
                    return float(asset['total']) # Assuming 'total' is the balance
            return 0.0
        except Exception as e:
            print(f"Error fetching USDC balance: {e}")
            return 0.0

    def get_funding_rate(self, coin: str = "ETH"):
        try:
            # Assuming get_funding_history() returns a list of dictionaries
            # with 'coin' and 'hourlyFundingRate'
            funding_history = self.info_client.get_funding_history()
            for entry in funding_history:
                if entry['coin'] == coin:
                    return float(entry['hourlyFundingRate'])
            return None
        except Exception as e:
            print(f"Error fetching funding rate: {e}")
            return None

    # Placeholder for position management functions
    def open_short_position(self, coin: str, sz: float):
        print(f"Attempting to open a short position for {sz} {coin}")
        # This would involve using self.exchange_client.order()
        # Need to define order parameters (limit price, order type, etc.)
        pass

    def close_position(self, coin: str):
        print(f"Attempting to close position for {coin}")
        # This would involve using self.exchange_client.cancel_all() or a specific close order
        pass
