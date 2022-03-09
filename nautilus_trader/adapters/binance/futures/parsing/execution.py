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

from decimal import Decimal
from typing import Any, Dict

from nautilus_trader.adapters.binance.futures.schemas.account import BinanceFuturesOrder
from nautilus_trader.core.datetime import millis_to_nanos
from nautilus_trader.core.uuid import UUID4
from nautilus_trader.execution.reports import OrderStatusReport
from nautilus_trader.execution.reports import PositionStatusReport
from nautilus_trader.execution.reports import TradeReport
from nautilus_trader.model.currency import Currency
from nautilus_trader.model.enums import LiquiditySide
from nautilus_trader.model.enums import OrderSide
from nautilus_trader.model.enums import OrderStatus
from nautilus_trader.model.enums import OrderType
from nautilus_trader.model.enums import PositionSide
from nautilus_trader.model.enums import TimeInForce
from nautilus_trader.model.enums import TriggerType
from nautilus_trader.model.identifiers import AccountId
from nautilus_trader.model.identifiers import ClientOrderId
from nautilus_trader.model.identifiers import InstrumentId
from nautilus_trader.model.identifiers import TradeId
from nautilus_trader.model.identifiers import VenueOrderId
from nautilus_trader.model.objects import Money
from nautilus_trader.model.objects import Price
from nautilus_trader.model.objects import Quantity
from nautilus_trader.model.orderbook.data import Order


def binance_order_type(order: Order) -> str:
    if order.type == OrderType.MARKET:
        return "MARKET"
    elif order.type == OrderType.LIMIT:
        return "LIMIT"
    elif order.type == OrderType.STOP_MARKET:
        return "STOP_MARKET"
    elif order.type == OrderType.STOP_LIMIT:
        return "STOP"
    elif order.type == OrderType.MARKET_IF_TOUCHED:
        return "TAKE_PROFIT_MARKET"
    elif order.type == OrderType.LIMIT_IF_TOUCHED:
        return "TAKE_PROFIT"
    elif order.type == OrderType.TRAILING_STOP_MARKET:
        return "TRAILING_STOP_MARKET"
    else:  # pragma: no cover (design-time error)
        raise RuntimeError("invalid order type")


def parse_order_type(order_type: str) -> OrderType:
    if order_type == "STOP":
        return OrderType.STOP_LIMIT
    elif order_type == "STOP_LOSS_LIMIT":
        return OrderType.STOP_LIMIT
    elif order_type == "TAKE_PROFIT":
        return OrderType.LIMIT_IF_TOUCHED
    elif order_type == "TAKE_PROFIT_LIMIT":
        return OrderType.STOP_LIMIT
    elif order_type == "TAKE_PROFIT_MARKET":
        return OrderType.MARKET_IF_TOUCHED
    else:
        return OrderType[order_type]


def parse_order_status(status: str) -> OrderStatus:
    if status == "NEW":
        return OrderStatus.ACCEPTED
    elif status == "CANCELED":
        return OrderStatus.CANCELED
    elif status == "PARTIALLY_FILLED":
        return OrderStatus.PARTIALLY_FILLED
    elif status == "FILLED":
        return OrderStatus.FILLED
    elif status == "EXPIRED":
        return OrderStatus.EXPIRED
    else:  # pragma: no cover (design-time error)
        raise RuntimeError(f"unrecognized order status, was {status}")


def parse_time_in_force(time_in_force: str) -> TimeInForce:
    if time_in_force == "GTX":
        return TimeInForce.GTC
    else:
        return TimeInForce[time_in_force]


def parse_trigger_type(working_type: str) -> TriggerType:
    if working_type == "CONTRACT_PRICE":
        return TriggerType.LAST
    elif working_type == "MARK_PRICE":
        return TriggerType.MARK
    else:  # pragma: no cover (design-time error)
        return TriggerType.NONE


def parse_order_report_http(
    account_id: AccountId,
    instrument_id: InstrumentId,
    msg: BinanceFuturesOrder,
    report_id: UUID4,
    ts_init: int,
) -> OrderStatusReport:
    price = Decimal(msg.price)
    trigger_price = Decimal(msg.stopPrice)
    avg_px = Decimal(msg.avgPrice)
    return OrderStatusReport(
        account_id=account_id,
        instrument_id=instrument_id,
        client_order_id=ClientOrderId(msg.clientOrderId) if msg.clientOrderId != "" else None,
        venue_order_id=VenueOrderId(str(msg.orderId)),
        order_side=OrderSide[msg.side.upper()],
        order_type=parse_order_type(msg.type.upper()),
        time_in_force=parse_time_in_force(msg.timeInForce.upper()),
        order_status=parse_order_status(msg.status.upper()),
        price=Price.from_str(msg.price) if price is not None else None,
        quantity=Quantity.from_str(msg.origQty),
        filled_qty=Quantity.from_str(msg.executedQty),
        avg_px=avg_px if avg_px > 0 else None,
        post_only=msg.timeInForce == "GTX",
        reduce_only=msg.reduceOnly,
        report_id=report_id,
        ts_accepted=millis_to_nanos(msg.time),
        ts_last=millis_to_nanos(msg.updateTime),
        ts_init=ts_init,
        trigger_price=Price.from_str(str(trigger_price)) if trigger_price > 0 else None,
        trigger_type=parse_trigger_type(msg.workingType),
    )


def parse_trade_report_http(
    account_id: AccountId,
    instrument_id: InstrumentId,
    data: Dict[str, Any],
    report_id: UUID4,
    ts_init: int,
) -> TradeReport:
    return TradeReport(
        account_id=account_id,
        instrument_id=instrument_id,
        venue_order_id=VenueOrderId(str(data["orderId"])),
        trade_id=TradeId(str(data["id"])),
        order_side=OrderSide[data["side"].upper()],
        last_qty=Quantity.from_str(data["qty"]),
        last_px=Price.from_str(data["price"]),
        commission=Money(data["commission"], Currency.from_str(data["commissionAsset"])),
        liquidity_side=LiquiditySide.MAKER if data["maker"] else LiquiditySide.TAKER,
        report_id=report_id,
        ts_event=millis_to_nanos(data["time"]),
        ts_init=ts_init,
    )


def parse_position_report_http(
    account_id: AccountId,
    instrument_id: InstrumentId,
    data: Dict[str, Any],
    report_id: UUID4,
    ts_init: int,
) -> PositionStatusReport:
    net_size = Decimal(data["positionAmt"])
    return PositionStatusReport(
        account_id=account_id,
        instrument_id=instrument_id,
        position_side=PositionSide.LONG if net_size > 0 else PositionSide.SHORT,
        quantity=Quantity.from_str(str(abs(net_size))),
        report_id=report_id,
        ts_last=ts_init,
        ts_init=ts_init,
    )
