# -------------------------------------------------------------------------------------------------
#  Copyright (C) 2015-2022 Nautech Systems Pty Ltd. All rights reserved.
#  https://nautechsystems.io
#
#  Licensed under the GNU Lesser General Public License Version 3.0 (the "License");
#  You may not use this file except in compliance with the License.
#  You may obtain a copy of the License at https://www.gnu.org/licenses/lgpl-3.0.en.html
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
# -------------------------------------------------------------------------------------------------

from typing import List, Optional

import msgspec

from nautilus_trader.adapters.binance.common.enums import BinanceOrderSide
from nautilus_trader.adapters.binance.common.enums import BinanceOrderStatus
from nautilus_trader.adapters.binance.futures.enums import BinanceFuturesExecutionType
from nautilus_trader.adapters.binance.futures.enums import BinanceFuturesOrderType
from nautilus_trader.adapters.binance.futures.enums import BinanceFuturesPositionSide
from nautilus_trader.adapters.binance.futures.enums import BinanceFuturesTimeInForce
from nautilus_trader.adapters.binance.futures.enums import BinanceFuturesWorkingType


class MarginCallPositionMsg(msgspec.Struct):
    """WebSocket message 'inner struct' position for Margin Call events."""

    s: str  # Symbol
    ps: BinanceFuturesPositionSide  # Position Side
    pa: str  # Position  Amount
    mt: str  # Margin Type
    iw: str  # Isolated Wallet(if isolated position)
    mp: str  # MarkPrice
    up: str  # Unrealized PnL
    mm: str  # Maintenance Margin Required


class BinanceFuturesMarginCallMsg(msgspec.Struct):
    """WebSocket message for Margin Call events."""

    e: str  # Event Type
    E: int  # Event Time
    cw: float  # Cross Wallet Balance. Only pushed with crossed position margin call
    p: List[MarginCallPositionMsg]


class BinanceFuturesOrderMsg(msgspec.Struct):
    """
    WebSocket message 'inner struct' for `BinanceFuturesOrderUpdateMsg`.

    Client Order ID 'c':
     - starts with "autoclose-": liquidation order/
     - starts with "adl_autoclose": ADL auto close order/
    """

    s: str  # Symbol
    c: str  # Client Order ID
    S: BinanceOrderSide  # Side
    o: BinanceFuturesOrderType  # Order Type
    f: BinanceFuturesTimeInForce  # Time in Force
    q: str  # Original Quantity
    p: str  # Original Price
    ap: str  # Average Price
    sp: str  # Stop Price. Please ignore with TRAILING_STOP_MARKET order
    x: BinanceFuturesExecutionType  # Execution Type
    X: BinanceOrderStatus  # Order Status
    i: int  # Order ID
    l: str  # Order Last Filled Quantity
    z: str  # Order Filled Accumulated Quantity
    L: str  # Last Filled Price
    N: Optional[str]  # Commission Asset, will not push if no commission
    n: Optional[str]  # Commission, will not push if no commission
    T: int  # Order Trade Time
    t: int  # Trade ID
    b: str  # Bids Notional
    a: str  # Ask Notional
    m: bool  # Is this trade the maker side?
    R: bool  # Is this reduce only
    wt: BinanceFuturesWorkingType  # Stop Price Working Type
    ot: BinanceFuturesOrderType  # Original Order Type
    ps: BinanceFuturesPositionSide  # Position Side
    cp: bool  # If Close-All, pushed with conditional order
    AP: str  # Activation Price, only pushed with TRAILING_STOP_MARKET order
    cr: str  # Callback Rate, only pushed with TRAILING_STOP_MARKET order
    pP: bool  # ignore
    si: int  # ignore
    ss: int  # ignore
    rp: str  # Realized Profit of the trade


class BinanceFuturesOrderUpdateMsg(msgspec.Struct):
    """WebSocket message for Order Update events."""

    e: str  # Event Type
    E: int  # Event Time
    T: int  # Transaction Time
    o: List[BinanceFuturesOrderMsg]
