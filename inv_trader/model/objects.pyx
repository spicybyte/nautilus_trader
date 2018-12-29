#!/usr/bin/env python3
# -------------------------------------------------------------------------------------------------
# <copyright file="objects.pyx" company="Invariance Pte">
#  Copyright (C) 2018-2019 Invariance Pte. All rights reserved.
#  The use of this source code is governed by the license as found in the LICENSE.md file.
#  http://www.invariance.com
# </copyright>
# -------------------------------------------------------------------------------------------------

# cython: language_level=3, boundscheck=False, wraparound=False

from datetime import datetime
from decimal import Decimal

from inv_trader.core.precondition cimport Precondition
from inv_trader.model.enums import Venue, Resolution, QuoteType, SecurityType, CurrencyCode


cdef class Symbol:
    """
    Represents the symbol for a financial market tradeable instrument.
    """
    cdef readonly str code
    cdef readonly object venue

    def __init__(self,
                 str code,
                 venue: Venue):
        """
        Initializes a new instance of the Symbol class.

        :param code: The symbols code.
        :param venue: The symbols venue.
        :raises ValueError: If the code is not a valid string.
        """
        Precondition.type(venue, Venue, 'venue')
        Precondition.valid_string(code, 'code')

        self.code = code.upper()
        self.venue = venue

    def __eq__(self, other) -> bool:
        """
        Override the default equality comparison.
        """
        if isinstance(other, self.__class__):
            return self.code == other.code and self.venue == other.venue
        else:
            return False

    def __ne__(self, other) -> bool:
        """
        Override the default not-equals comparison.
        """
        return not self.__eq__(other)

    def __hash__(self) -> int:
        """"
        Override the default hash implementation.
        """
        return hash((self.code, self.venue))

    def __str__(self) -> str:
        """
        :return: The str() string representation of the symbol.
        """
        return str(f"{self.code}.{self.venue.name}")

    def __repr__(self) -> str:
        """
        :return: The repr() string representation of the symbol.
        """
        return str(f"<{str(self)} object at {id(self)}>")


cdef class Price:
    """
    Provides a factory for creating Decimal objects representing price.
    """

    @staticmethod
    def create(double price,
               int decimals):
        """
        Creates and returns a new price from the given values.
        The price is rounded to the given decimal digits.

        :param price: The price value.
        :param decimals: The decimal precision of the price.
        :return: A Decimal representing the price.
        :raises ValueError: If the price is not positive (> 0).
        :raises ValueError: If the decimals is negative (< 0).
        """
        Precondition.positive(price, 'price')
        Precondition.not_negative(decimals, 'decimals')

        return Decimal(f'{round(price, decimals):.{decimals}f}')


cdef class Money:
    """
    Provides a factory for creating Decimal objects representing money.
    """

    @staticmethod
    def zero() -> Decimal:
        """
        Creates and returns a new zero amount of money.

        :return:
        """
        return Decimal('0.00')

    @staticmethod
    def create(double amount) -> Decimal:
        """
        Creates and returns money from the given values.
        The money is rounded to two decimal digits.

        :param amount: The money amount.
        :return: A Decimal representing the money.
        :raises ValueError: If the amount is not positive (> 0).
        """
        Precondition.positive(amount, 'amount')

        return Decimal(f'{round(amount, 2):.{2}f}')


cdef class Tick:
    """
    Represents a single tick in a financial market.
    """
    cdef readonly object symbol
    cdef readonly object bid
    cdef readonly object ask
    cdef readonly object timestamp

    def __init__(self,
                 symbol: Symbol,
                 bid: Decimal,
                 ask: Decimal,
                 timestamp: datetime):
        """
        Initializes a new instance of the Tick class.

        :param symbol: The tick symbol.
        :param bid: The tick best bid price.
        :param ask: The tick best ask price.
        :param timestamp: The tick timestamp (UTC).
        :raises ValueError: If the bid is not positive (> 0).
        :raises ValueError: If the ask is not positive (> 0).
        """
        Precondition.type(symbol, Symbol, 'symbol')
        Precondition.type(bid, Decimal, 'bid')
        Precondition.type(ask, Decimal, 'ask')
        Precondition.type(timestamp, datetime, 'timestamp')
        Precondition.positive(bid, 'bid')
        Precondition.positive(ask, 'ask')

        self.symbol = symbol
        self.bid = bid
        self.ask = ask
        self.timestamp = timestamp

    def __eq__(self, other) -> bool:
        """
        Override the default equality comparison.
        """
        if isinstance(other, self.__class__):
            return (self.symbol == other.symbol
                    and self.bid == other.bid
                    and self.ask == other.ask
                    and self.timestamp == other.timestamp)
        else:
            return False

    def __ne__(self, other) -> bool:
        """
        Override the default not-equals comparison.
        """
        return not self.__eq__(other)

    def __hash__(self) -> int:
        """"
        Override the default hash implementation.
        """
        return hash(self.timestamp)

    def __str__(self) -> str:
        """
        :return: The str() string representation of the tick.
        """
        return str(f"Tick({self.symbol},{self.bid},{self.ask},"
                f"{self.timestamp.isoformat()})")

    def __repr__(self) -> str:
        """
        :return: The repr() string representation of the tick.
        """
        return str(f"<{str(self)} object at {id(self)}>")


cdef class BarType:
    """
    Represents a financial market symbol and bar specification.
    """
    cdef readonly object symbol
    cdef readonly int period
    cdef readonly object resolution
    cdef readonly object quote_type

    def __init__(self,
                 symbol: Symbol,
                 int period,
                 resolution: Resolution,
                 quote_type: QuoteType):
        """
        Initializes a new instance of the BarType class.

        :param symbol: The bar symbol.
        :param period: The bar period.
        :param resolution: The bar resolution.
        :param quote_type: The bar quote type.
        :raises ValueError: If the period is not positive (> 0).
        """
        Precondition.type(symbol, Symbol, 'symbol')
        Precondition.type(resolution, Resolution, 'resolution')
        Precondition.type(quote_type, QuoteType, 'quote_type')
        Precondition.positive(period, 'period')

        self.symbol = symbol
        self.period = period
        self.resolution = resolution
        self.quote_type = quote_type

    def __eq__(self, other) -> bool:
        """
        Override the default equality comparison.
        """
        if isinstance(other, self.__class__):
            return (self.symbol == other.symbol
                    and self.period == other.period
                    and self.resolution == other.resolution
                    and self.quote_type == other.quote_type)
        else:
            return False

    def __ne__(self, other) -> bool:
        """
        Override the default not-equals comparison.
        """
        return not self.__eq__(other)

    def __hash__(self) -> int:
        """"
        Override the default hash implementation.
        """
        return hash((self.symbol, self.period, self.resolution, self.quote_type))

    def __str__(self) -> str:
        """
        :return: The str() string representation of the bar type.
        """
        return str(f"{str(self.symbol)}"
                f"-{self.period}-{self.resolution.name}[{self.quote_type.name}]")

    def __repr__(self) -> str:
        """
        :return: The repr() string representation of the bar type.
        """
        return str(f"<{str(self)} object at {id(self)}>")


cdef class Bar:
    """
    Represents a financial market trade bar.
    """
    cdef readonly object open
    cdef readonly object high
    cdef readonly object low
    cdef readonly object close
    cdef readonly int volume
    cdef readonly object timestamp

    def __init__(self,
                 open_price: Decimal,
                 high_price: Decimal,
                 low_price: Decimal,
                 close_price: Decimal,
                 int volume,
                 timestamp: datetime):
        """
        Initializes a new instance of the Bar class.

        :param open_price: The bars open price.
        :param high_price: The bars high price.
        :param low_price: The bars low price.
        :param close_price: The bars close price.
        :param volume: The bars volume.
        :param timestamp: The bars timestamp (UTC).
        :raises ValueError: If the open_price is not positive (> 0).
        :raises ValueError: If the high_price is not positive (> 0).
        :raises ValueError: If the low_price is not positive (> 0).
        :raises ValueError: If the close_price is not positive (> 0).
        :raises ValueError: If the volume is negative.
        :raises ValueError: If the high_price is not >= low_price.
        :raises ValueError: If the high_price is not >= close_price.
        :raises ValueError: If the low_price is not <= close_price.
        """
        Precondition.type(open_price, Decimal, 'open_price')
        Precondition.type(high_price, Decimal, 'high_price')
        Precondition.type(low_price, Decimal, 'low_price')
        Precondition.type(close_price, Decimal, 'close_price')
        Precondition.type(timestamp, datetime, 'timestamp')
        Precondition.positive(open_price, 'open_price')
        Precondition.positive(high_price, 'high_price')
        Precondition.positive(low_price, 'low_price')
        Precondition.positive(close_price, 'close_price')
        Precondition.not_negative(volume, 'volume')
        Precondition.true(high_price >= low_price, 'high_price >= low_price')
        Precondition.true(high_price >= close_price, 'high_price >= close_price')
        Precondition.true(low_price <= close_price, 'low_price <= close_price')

        self.open = open_price
        self.high = high_price
        self.low = low_price
        self.close = close_price
        self.volume = volume
        self.timestamp = timestamp

    def __eq__(self, other) -> bool:
        """
        Override the default equality comparison.
        """
        if isinstance(other, self.__class__):
            return self.timestamp == other.timestamp
        else:
            return False

    def __ne__(self, other) -> bool:
        """
        Override the default not-equals comparison.
        """
        return not self.__eq__(other)

    def __hash__(self) -> int:
        """"
        Override the default hash implementation.
        """
        return hash(str(self.timestamp))

    def __str__(self) -> str:
        """
        :return: The str() string representation of the bar.
        """
        return str(f"Bar({self.open},{self.high},{self.low},{self.close},"
                f"{self.volume},{self.timestamp.isoformat()})")

    def __repr__(self) -> str:
        """
        :return: The repr() string representation of the bar.
        """
        return str(f"<{str(self)} object at {id(self)}>")


cdef class DataBar:
    """
    Represents a financial market trade bar.

    Note: To properly instantiate this class use the cython fast init method
    by calling DataBar.__new__().
    """
    cdef readonly double open
    cdef readonly double high
    cdef readonly double low
    cdef readonly double close
    cdef readonly double volume
    cdef readonly object timestamp

    def __init__(self,
                 double open_price,
                 double high_price,
                 double low_price,
                 double close_price,
                 double volume,
                 timestamp: datetime):
        """
        Initializes a new instance of the DataBar class.

        :param open_price: The bars open price.
        :param high_price: The bars high price.
        :param low_price: The bars low price.
        :param close_price: The bars close price.
        :param volume: The bars volume.
        :param timestamp: The bars timestamp (UTC).
        :raises ValueError: If the open_price is not positive (> 0).
        :raises ValueError: If the high_price is not positive (> 0).
        :raises ValueError: If the low_price is not positive (> 0).
        :raises ValueError: If the close_price is not positive (> 0).
        :raises ValueError: If the volume is negative.
        """
        Precondition.type(timestamp, datetime, 'timestamp')

        self.open = open_price
        self.high = high_price
        self.low = low_price
        self.close = close_price
        self.volume = volume
        self.timestamp = timestamp

    def __eq__(self, other) -> bool:
        """
        Override the default equality comparison.
        """
        if isinstance(other, self.__class__):
            return self.open == other.open
        else:
            return False

    def __ne__(self, other) -> bool:
        """
        Override the default not-equals comparison.
        """
        return not self.__eq__(other)

    def __hash__(self) -> int:
        """"
        Override the default hash implementation.
        """
        return hash(str(self.timestamp))

    def __str__(self) -> str:
        """
        :return: The str() string representation of the bar.
        """
        return str(f"Bar({self.open},{self.high},{self.low},{self.close},"
                f"{self.volume},{self.timestamp.isoformat()})")

    def __repr__(self) -> str:
        """
        :return: The repr() string representation of the bar.
        """
        return str(f"<{str(self)} object at {id(self)}>")


cdef class Instrument:
    """
    Represents a tradeable financial market instrument.
    """
    cdef readonly object symbol
    cdef readonly str broker_symbol
    cdef readonly object quote_currency
    cdef readonly object security_type
    cdef readonly int tick_decimals
    cdef readonly object tick_size
    cdef readonly object tick_value
    cdef readonly object target_direct_spread
    cdef readonly int round_lot_size
    cdef readonly int contract_size
    cdef readonly int min_stop_distance_entry
    cdef readonly int min_limit_distance_entry
    cdef readonly int min_stop_distance
    cdef readonly int min_limit_distance
    cdef readonly int min_trade_size
    cdef readonly int max_trade_size
    cdef readonly object margin_requirement
    cdef readonly object rollover_interest_buy
    cdef readonly object rollover_interest_sell
    cdef readonly object timestamp

    def __init__(self,
                 symbol: Symbol,
                 str broker_symbol,
                 quote_currency: CurrencyCode,
                 security_type: SecurityType,
                 int tick_decimals,
                 tick_size: Decimal,
                 tick_value: Decimal,
                 target_direct_spread: Decimal,
                 int round_lot_size,
                 int contract_size,
                 int min_stop_distance_entry,
                 int min_limit_distance_entry,
                 int min_stop_distance,
                 int min_limit_distance,
                 int min_trade_size,
                 int max_trade_size,
                 margin_requirement: Decimal,
                 rollover_interest_buy: Decimal,
                 rollover_interest_sell: Decimal,
                 timestamp: datetime):
        """
        Initializes a new instance of the Instrument class.

        :param symbol: The instruments symbol.
        :param broker_symbol: The instruments broker symbol.
        :param quote_currency: The instruments quote currency.
        :param security_type: The instruments security type.
        :param tick_decimals: The instruments tick decimal digits precision.
        :param tick_size: The instruments tick size.
        :param tick_value: The instruments tick value.
        :param target_direct_spread: The instruments target direct spread (set by broker).
        :param round_lot_size: The instruments rounded lot size.
        :param contract_size: The instruments contract size if applicable.
        :param min_stop_distance_entry: The instruments minimum distance for stop entry orders.
        :param min_limit_distance_entry: The instruments minimum distance for limit entry orders.
        :param min_stop_distance: The instruments minimum tick distance for stop orders.
        :param min_limit_distance: The instruments minimum tick distance for limit orders.
        :param min_trade_size: The instruments minimum trade size.
        :param max_trade_size: The instruments maximum trade size.
        :param margin_requirement: The instruments margin requirement per unit.
        :param rollover_interest_buy: The instruments rollover interest for long positions.
        :param rollover_interest_sell: The instruments rollover interest for short positions.
        :param timestamp: The timestamp the instrument was created/updated at.
        """
        Precondition.type(symbol, Symbol, 'symbol')
        Precondition.type(quote_currency, CurrencyCode, 'quote_currency')
        Precondition.type(security_type, SecurityType, 'security_type')
        Precondition.type(tick_size, Decimal, 'tick_size')
        Precondition.type(tick_value, Decimal, 'tick_value')
        Precondition.type(target_direct_spread, Decimal, 'target_direct_spread')
        Precondition.type(margin_requirement, Decimal, 'margin_requirement')
        Precondition.type(rollover_interest_buy, Decimal, 'rollover_interest_buy')
        Precondition.type(rollover_interest_sell, Decimal, 'rollover_interest_sell')
        Precondition.type(timestamp, datetime, 'timestamp')
        Precondition.valid_string(broker_symbol, 'broker_symbol')
        Precondition.not_negative(tick_decimals, 'tick_decimals')
        Precondition.positive(tick_size, 'tick_size')
        Precondition.positive(tick_value, 'tick_value')
        Precondition.not_negative(target_direct_spread, 'target_direct_spread')
        Precondition.positive(contract_size, 'contract_size')
        Precondition.not_negative(min_stop_distance_entry, 'min_stop_distance_entry')
        Precondition.not_negative(min_limit_distance_entry, 'min_limit_distance_entry')
        Precondition.not_negative(min_stop_distance, 'min_stop_distance')
        Precondition.not_negative(min_limit_distance, 'min_limit_distance')
        Precondition.not_negative(min_limit_distance, 'min_limit_distance')
        Precondition.positive(min_trade_size, 'min_trade_size')
        Precondition.positive(max_trade_size, 'max_trade_size')
        Precondition.not_negative(margin_requirement, 'margin_requirement')

        self.symbol = symbol
        self.broker_symbol = broker_symbol
        self.quote_currency = quote_currency
        self.security_type = security_type
        self.tick_decimals = tick_decimals
        self.tick_size = tick_size
        self.tick_value = tick_value
        self.target_direct_spread = target_direct_spread
        self.round_lot_size = round_lot_size
        self.contract_size = contract_size
        self.min_stop_distance_entry = min_stop_distance_entry
        self.min_limit_distance_entry = min_limit_distance_entry
        self.min_stop_distance = min_stop_distance
        self.min_limit_distance = min_limit_distance
        self.min_trade_size = min_trade_size
        self.max_trade_size = max_trade_size
        self.margin_requirement = margin_requirement
        self.rollover_interest_buy = rollover_interest_buy
        self.rollover_interest_sell = rollover_interest_sell
        self.timestamp = timestamp

    def __eq__(self, other) -> bool:
        """
        Override the default equality comparison.
        """
        if isinstance(other, self.__class__):
            return self.symbol == other.symbol
        else:
            return False

    def __ne__(self, other) -> bool:
        """
        Override the default not-equals comparison.
        """
        return not self.__eq__(other)

    def __hash__(self) -> int:
        """"
        Override the default hash implementation.
        """
        return hash(str(self.symbol))

    def __str__(self) -> str:
        """
        :return: The str() string representation of the instrument.
        """
        return str(f"Instrument({self.symbol.code}.{self.symbol.venue})")

    def __repr__(self) -> str:
        """
        :return: The repr() string representation of the instrument.
        """
        return str(f"<{str(self)} object at {id(self)}>")
