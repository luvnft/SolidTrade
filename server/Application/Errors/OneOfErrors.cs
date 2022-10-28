using Application.Errors.Base;

namespace Application.Errors;

public class NotAuthenticated : BaseError { }
public class NotAuthorized : BaseError { }
// Todo: Delete UnexpectedError class and create classes for each error.
public class UnexpectedError : BaseError { }
public class NotFound : BaseError { }
    
public class UserCreateFailed : BaseError { }
public class UserUpdateFailed : BaseError { }
public class UserDeleteFailed : BaseError { }
        
public class TradeFailed : BaseError { }
public class InsufficientFounds : BaseError { }
public class StockMarketClosed : BaseError { }
public class InvalidState : BaseError { }