//
//  StoryboardSegueIdentifierProtocol.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 06-12-15.
//  From: https://github.com/mac-cain13/R.swift
//

import Foundation

/// Storyboard reference
public protocol StoryboardReference {
    /// Name of the storyboard file on disk
    var name: String { get }

    /// Bundle this storyboard is in
    var bundle: Bundle { get }
}


public protocol InitialControllerContainer {
    /// Type of the inital controller
    associatedtype InitialController
}


/// Storyboard view controller identifier
public struct StoryboardViewControllerIdentifier<ViewController> {

    /// Storyboard identifier of this view controller
    public let identifier: String

    /// Name of the storyboard file on disk
    public let storyboard: String

    /// Bundle this storyboard is in
    public let bundle: Bundle

    /**
     Create a new StoryboardViewControllerIdentifier based on the identifier string
     - parameter identifier: The string identifier for this view controller
     - parameter storyboard: The name of the storyboard file
     - parameter bundle: The bundle the storyboard is in
    */
    public init(identifier: String, storyboard: String, bundle: Bundle) {
        self.identifier = identifier
        self.storyboard = storyboard
        self.bundle = bundle
    }
}

public protocol NibReferenceContainer {
    associatedtype FirstView
    var name: String { get }
    var bundle: Bundle { get }
}

public protocol ReuseIdentifierContainer<Reusable> {
    associatedtype Reusable
    var identifier: String { get }
}

/// Nib reference
public struct NibReference<FirstView>: NibReferenceContainer {

    /// String name of this nib
    public let name: String

    /// Bundle this nib is in
    public let bundle: Bundle

    /**
     Create a new NibRefence based on the name string
     - parameter name: The string name for this nib
     - parameter bundle: The bundle the nib is in
    */
    public init(name: String, bundle: Bundle) {
        self.name = name
        self.bundle = bundle
    }
}

/// Reuse identifier
public struct ReuseIdentifier<Reusable>: ReuseIdentifierContainer {

    /// String identifier of this reusable
    public let identifier: String

    /**
     Create a new ReuseIdentifier based on the string identifier
     - parameter identifier: The string identifier for this reusable
     - returns: A new ReuseIdentifier
    */
    public init(identifier: String) {
        self.identifier = identifier
    }
}

/// Nib reference, reuse identifier
public struct NibReferenceReuseIdentifier<FirstView, Reusable>: NibReferenceContainer, ReuseIdentifierContainer {

    /// String name of this nib
    public let name: String

    /// Bundle this nib is in
    public let bundle: Bundle

    /// String identifier of this reusable
    public let identifier: String

    /**
     Create a new NibRefence based on the name string
     - parameter name: The string name for this nib
     - parameter bundle: The bundle the nib is in
     - parameter identifier: The string identifier for this reusable
    */
    public init(name: String, bundle: Bundle, identifier: String) {
        self.name = name
        self.bundle = bundle
        self.identifier = identifier
    }
}

/// Segue identifier
public struct SegueIdentifier<Segue, Source, Destination> {

    /// Identifier string of this segue
    public let identifier: String

    /**
     Create a new SegueIdentifier based on the identifier string
     - parameter identifier: The string identifier for this segue
     - returns: A new SegueIdentifier
    */
    public init(identifier: String) {
        self.identifier = identifier
    }
}

/// Typed segue information
public struct TypedSegue<Segue, Source, Destination> {

    /// The original segue
    public let segue: Segue

    /// Segue source view controller
    public let source: Source

    /// Segue destination view controller
    public let destination: Destination

    /// Segue identifier
    public let identifier: String

    /**
     Create a new TypedSegue based on the original segue
     - parameter segue: The original segue
     - parameter source: Segue source view controller
     - parameter destination: Segue destination view controller
     - parameter identifier: The string identifier for this segue
     - returns: A new TypedSegue
    */
    public init(segue: Segue, source: Source, destination: Destination, identifier: String) {
        self.segue = segue
        self.source = source
        self.destination = destination
        self.identifier = identifier
    }
}


@available(*, renamed: "ReuseIdentifierContainer")
public protocol ReuseIdentifierType {}

@available(*, renamed: "SegueIdentifier")
public struct StoryboardSegueIdentifier<Segue, Self, Destination> {}

@available(*, renamed: "TypedSegue")
public struct TypedStoryboardSegueInfo<Segue, Source, Destination> {}
